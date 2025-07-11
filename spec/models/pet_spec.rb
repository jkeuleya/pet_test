require 'rails_helper'

RSpec.describe Pet, type: :model do
  describe 'associations' do
    it { should have_many(:vaccination_records).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(100) }

    it { should validate_presence_of(:breed) }
    it { should validate_length_of(:breed).is_at_least(2).is_at_most(100) }

    it { should validate_presence_of(:age) }
    it { should validate_numericality_of(:age).only_integer }
    it { should validate_numericality_of(:age).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:age).is_less_than_or_equal_to(30) }
  end

  describe 'scopes' do
    let!(:young_pet) { create(:pet, age: 1) }
    let!(:adult_pet) { create(:pet, age: 5) }
    let!(:senior_pet) { create(:pet, age: 10) }

    describe '.young' do
      it 'returns pets younger than 2 years' do
        expect(Pet.young).to include(young_pet)
        expect(Pet.young).not_to include(adult_pet, senior_pet)
      end
    end

    describe '.adult' do
      it 'returns pets between 2 and 7 years' do
        expect(Pet.adult).to include(adult_pet)
        expect(Pet.adult).not_to include(young_pet, senior_pet)
      end
    end

    describe '.senior' do
      it 'returns pets 8 years or older' do
        expect(Pet.senior).to include(senior_pet)
        expect(Pet.senior).not_to include(young_pet, adult_pet)
      end
    end

    describe '.by_breed' do
      let!(:labrador) { create(:pet, breed: 'Labrador') }
      let!(:siamese) { create(:pet, breed: 'Siamese') }

      it 'returns pets of specified breed' do
        expect(Pet.by_breed('Labrador')).to include(labrador)
        expect(Pet.by_breed('Labrador')).not_to include(siamese)
      end
    end
  end

  describe 'instance methods' do
    describe '#age_category' do
      it 'returns correct category for young pets' do
        pet = build(:pet, age: 1)
        expect(pet.age_category).to eq('young')
      end

      it 'returns correct category for adults' do
        pet = build(:pet, age: 5)
        expect(pet.age_category).to eq('adult')
      end

      it 'returns correct category for seniors' do
        pet = build(:pet, age: 10)
        expect(pet.age_category).to eq('senior')
      end
    end

    describe '#has_expired_vaccinations?' do
      let(:pet) { create(:pet) }

      context 'with expired vaccinations' do
        before do
          create(:vaccination_record, pet: pet, expired: true)
        end

        it 'returns true' do
          expect(pet.has_expired_vaccinations?).to be true
        end
      end

      context 'without expired vaccinations' do
        before do
          create(:vaccination_record, pet: pet, expired: false)
        end

        it 'returns false' do
          expect(pet.has_expired_vaccinations?).to be false
        end
      end
    end

    describe '#upcoming_vaccination_expirations' do
      let(:pet) { create(:pet) }
      let!(:expired) { create(:vaccination_record, pet: pet, expired: true) }
      let!(:expiring_soon) { create(:vaccination_record, pet: pet, expired: false, expiry_date: 10.days.from_now) }
      let!(:expiring_later) { create(:vaccination_record, pet: pet, expired: false, expiry_date: 60.days.from_now) }

      it 'returns only non-expired vaccinations expiring within specified days' do
        results = pet.upcoming_vaccination_expirations(30)
        expect(results).to include(expiring_soon)
        expect(results).not_to include(expired, expiring_later)
      end

      it 'orders by expiry date ascending' do
        another_expiring = create(:vaccination_record, pet: pet, expired: false, expiry_date: 5.days.from_now)
        results = pet.upcoming_vaccination_expirations(30)
        expect(results.first).to eq(another_expiring)
        expect(results.second).to eq(expiring_soon)
      end
    end
  end
end
