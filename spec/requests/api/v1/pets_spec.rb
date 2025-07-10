require 'rails_helper'

RSpec.describe "Api::V1::Pets", type: :request do
  let(:valid_attributes) {
    { name: "Max", breed: "Labrador", age: 3 }
  }

  let(:invalid_attributes) {
    { name: "", breed: "Labrador", age: -1 }
  }

  describe "GET /api/v1/pets" do
    before do
      create_list(:pet, 30)
    end

    it "returns a successful response" do
      get "/api/v1/pets"
      expect(response).to have_http_status(:success)
    end

    it "returns paginated results" do
      get "/api/v1/pets"
      json = JSON.parse(response.body)
      expect(json['pets'].count).to eq(25) # Default per_page
      expect(json['meta']['total_count']).to eq(30)
    end

    it "respects per_page parameter" do
      get "/api/v1/pets", params: { per_page: 10 }
      json = JSON.parse(response.body)
      expect(json['pets'].count).to eq(10)
    end

    it "filters by breed" do
      labrador = create(:pet, breed: "Labrador")
      siamese = create(:pet, breed: "Siamese")

      get "/api/v1/pets", params: { breed: "Labrador" }
      json = JSON.parse(response.body)

      pet_ids = json['pets'].map { |p| p['id'] }
      expect(pet_ids).to include(labrador.id)
      expect(pet_ids).not_to include(siamese.id)
    end

    it "filters by age category" do
      young = create(:pet, :young)
      adult = create(:pet, :adult)

      get "/api/v1/pets", params: { age_category: "young" }
      json = JSON.parse(response.body)

      pet_ids = json['pets'].map { |p| p['id'] }
      expect(pet_ids).to include(young.id)
      expect(pet_ids).not_to include(adult.id)
    end

    it "filters by expired vaccinations" do
      pet_with_expired = create(:pet, :with_expired_vaccinations)
      pet_without_expired = create(:pet, :with_vaccinations)

      get "/api/v1/pets", params: { has_expired_vaccinations: "true" }
      json = JSON.parse(response.body)

      pet_ids = json['pets'].map { |p| p['id'] }
      expect(pet_ids).to include(pet_with_expired.id)
    end
  end

  describe "GET /api/v1/pets/:id" do
    let(:pet) { create(:pet) }

    it "returns the pet" do
      get "/api/v1/pets/#{pet.id}"
      expect(response).to have_http_status(:success)

      json = JSON.parse(response.body)
      expect(json['pet']['id']).to eq(pet.id)
      expect(json['pet']['name']).to eq(pet.name)
    end

    it "returns 404 for non-existent pet" do
      get "/api/v1/pets/999999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/pets" do
    context "with valid parameters" do
      it "creates a new Pet" do
        expect {
          post "/api/v1/pets", params: { pet: valid_attributes }
        }.to change(Pet, :count).by(1)
      end

      it "returns created status" do
        post "/api/v1/pets", params: { pet: valid_attributes }
        expect(response).to have_http_status(:created)
      end

      it "returns the created pet" do
        post "/api/v1/pets", params: { pet: valid_attributes }
        json = JSON.parse(response.body)
        expect(json['pet']['name']).to eq("Max")
      end
    end

    context "with invalid parameters" do
      it "does not create a new Pet" do
        expect {
          post "/api/v1/pets", params: { pet: invalid_attributes }
        }.to change(Pet, :count).by(0)
      end

      it "returns unprocessable entity status" do
        post "/api/v1/pets", params: { pet: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error messages" do
        post "/api/v1/pets", params: { pet: invalid_attributes }
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
      end
    end
  end

  describe "PATCH /api/v1/pets/:id" do
    let(:pet) { create(:pet) }
    let(:new_attributes) { { age: 5 } }

    context "with valid parameters" do
      it "updates the pet" do
        patch "/api/v1/pets/#{pet.id}", params: { pet: new_attributes }
        pet.reload
        expect(pet.age).to eq(5)
      end

      it "returns success status" do
        patch "/api/v1/pets/#{pet.id}", params: { pet: new_attributes }
        expect(response).to have_http_status(:success)
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity status" do
        patch "/api/v1/pets/#{pet.id}", params: { pet: { age: -1 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /api/v1/pets/:id" do
    let!(:pet) { create(:pet) }

    it "destroys the pet" do
      expect {
        delete "/api/v1/pets/#{pet.id}"
      }.to change(Pet, :count).by(-1)
    end

    it "returns no content status" do
      delete "/api/v1/pets/#{pet.id}"
      expect(response).to have_http_status(:no_content)
    end

    it "also destroys associated vaccination records" do
      create_list(:vaccination_record, 3, pet: pet)

      expect {
        delete "/api/v1/pets/#{pet.id}"
      }.to change(VaccinationRecord, :count).by(-3)
    end
  end
end
