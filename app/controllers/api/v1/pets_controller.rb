module Api
  module V1
    class PetsController < BaseController
      before_action :set_pet, only: [:show, :update, :destroy]

      def index
        pets = Pet.includes(:vaccination_records)
        pets = filter_pets(pets)

        result = paginate(pets)
        render_success(
          result[:data],
          serializer: PetSerializer,
          meta: result[:meta]
        )
      end

      def show
        render_success(@pet, serializer: PetSerializer)
      end

      def create
        pet = Pet.new(pet_params)

        if pet.save
          render_success(
            pet,
            serializer: PetSerializer,
            status: :created
          )
        else
          render_error(
            'Failed to create pet',
            errors: pet.errors.full_messages
          )
        end
      end

      def update
        if @pet.update(pet_params)
          render_success(@pet, serializer: PetSerializer)
        else
          render_error(
            'Failed to update pet',
            errors: @pet.errors.full_messages
          )
        end
      end

      def destroy
        @pet.destroy
        head :no_content
      end

      private

      def set_pet
        @pet = Pet.find(params[:id])
      end

      def pet_params
        params.require(:pet).permit(:name, :breed, :age)
      end

      def filter_pets(pets)
        pets = pets.by_breed(params[:breed]) if params[:breed].present?
        pets = pets.young if params[:age_category] == 'young'
        pets = pets.adult if params[:age_category] == 'adult'
        pets = pets.senior if params[:age_category] == 'senior'

        # Filter for pets with expired vaccinations
        if params[:has_expired_vaccinations].present?
          pet_ids = Pet.joins(:vaccination_records)
                       .where(vaccination_records: { expired: true })
                       .distinct
                       .pluck(:id)
          pets = params[:has_expired_vaccinations] == 'true' ?
                   pets.where(id: pet_ids) :
                   pets.where.not(id: pet_ids)
        end

        pets.order(created_at: :desc)
      end
    end
  end
end
