module Api
  module V1
    class BaseController < ApplicationController
      include Pagination

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
      rescue_from ActionController::ParameterMissing, with: :bad_request

      private

      def not_found(exception)
        render json: {
          error: 'Record not found',
          message: exception.message
        }, status: :not_found
      end

      def unprocessable_entity(exception)
        render json: {
          error: 'Validation failed',
          message: exception.message,
          errors: exception.record.errors.full_messages
        }, status: :unprocessable_entity
      end

      def bad_request(exception)
        render json: {
          error: 'Bad request',
          message: exception.message
        }, status: :bad_request
      end

      def render_success(data, status: :ok, serializer: nil, meta: {})
        if serializer && data.respond_to?(:each)
          # Handle collections
          render json: data,
                 each_serializer: serializer,
                 meta: meta,
                 adapter: :json,
                 status: status
        elsif serializer
          # Handle single objects
          render json: data,
                 serializer: serializer,
                 meta: meta,
                 adapter: :json,
                 status: status
        else
          # No serializer specified
          render json: data,
                 meta: meta,
                 status: status
        end
      end

      def render_error(message, status: :unprocessable_entity, errors: [])
        render json: {
          error: message,
          errors: errors
        }, status: status
      end
    end
  end
end
