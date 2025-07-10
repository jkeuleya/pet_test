module Api
  module V1
    class VaccinationRecordsController < BaseController
      before_action :set_pet
      before_action :set_vaccination_record, only: [:show, :update, :destroy, :mark_as_expired]

      def index
        records = @pet.vaccination_records
        records = filter_records(records)

        result = paginate(records)
        render_success(
          result[:data],
          serializer: VaccinationRecordSerializer,
          meta: result[:meta]
        )
      end

      def show
        render_success(@vaccination_record, serializer: VaccinationRecordSerializer)
      end

      def create
        vaccination_record = @pet.vaccination_records.build(vaccination_record_params)

        if vaccination_record.save
          render_success(
            vaccination_record,
            serializer: VaccinationRecordSerializer,
            status: :created
          )
        else
          render_error(
            'Failed to create vaccination record',
            errors: vaccination_record.errors.full_messages
          )
        end
      end

      def update
        if @vaccination_record.update(vaccination_record_params)
          render_success(@vaccination_record, serializer: VaccinationRecordSerializer)
        else
          render_error(
            'Failed to update vaccination record',
            errors: @vaccination_record.errors.full_messages
          )
        end
      end

      def destroy
        @vaccination_record.destroy
        head :no_content
      end

      def mark_as_expired
        if @vaccination_record.expired?
          render_error('Vaccination record is already marked as expired', status: :bad_request)
        else
          @vaccination_record.mark_as_expired!
          render_success(
            @vaccination_record,
            serializer: VaccinationRecordSerializer,
            status: :ok
          )
        end
      end

      private

      def set_pet
        @pet = Pet.find(params[:pet_id])
      end

      def set_vaccination_record
        @vaccination_record = @pet.vaccination_records.find(params[:id])
      end

      def vaccination_record_params
        params.require(:vaccination_record).permit(:name, :vaccination_date, :expiry_date)
      end

      def filter_records(records)
        records = records.expired if params[:status] == 'expired'
        records = records.active if params[:status] == 'active'
        records = records.expiring_soon(params[:days_until_expiry].to_i) if params[:days_until_expiry].present?

        records.order(expiry_date: :asc)
      end
    end
  end
end
