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
        # Apply breed filter
        pets = pets.by_breed(params[:breed]) if params[:breed].present?

        # Apply age category filter using scopes
        pets = case params[:age_category]
               when 'young' then pets.young
               when 'adult' then pets.adult
               when 'senior' then pets.senior
               else pets
               end

        # Optimize expired vaccinations filter with a single query
        if params[:has_expired_vaccinations].present?
          pets = if params[:has_expired_vaccinations] == 'true'
                   pets.with_expired_vaccinations
                 else
                   pets.without_expired_vaccinations
                 end
        end

        # Apply sorting with whitelisted fields
        apply_sorting(pets)
      end

      # Can be little bit heavy too on large datasets, just had fun here. Can be reworked
      def apply_sorting(scope)
        return scope.order(created_at: :desc) if params[:sort].blank?

        # Whitelist sortable fields for security
        sortable_fields = %w[name breed age created_at updated_at]
        field = params[:sort].gsub(/^-/, '')
        direction = params[:sort].start_with?('-') ? :desc : :asc

        if sortable_fields.include?(field)
          scope.order(field => direction)
        else
          scope.order(created_at: :desc)
        end
      end
    end
  end
end
