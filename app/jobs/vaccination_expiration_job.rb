class VaccinationExpirationJob < ApplicationJob
  queue_as :default

  # Retry configuration for resilience
  sidekiq_options retry: 3, dead: false

  # Error handling with exponential backoff retry
  sidekiq_retry_in do |count, exception|
    case count
    when 0 then 10.seconds
    when 1 then 1.minute
    when 2 then 5.minutes
    else
      # After 3 attempts, give up
      nil
    end
  end

  def perform(vaccination_record_id)
    vaccination_record = VaccinationRecord.find_by(id: vaccination_record_id)

    # If record no longer exists, stop the job
    return unless vaccination_record

    # Simulate email sending
    Rails.logger.info "=" * 60
    Rails.logger.info "VACCINATION EXPIRATION NOTIFICATION"
    Rails.logger.info "=" * 60
    Rails.logger.info "Pet: #{vaccination_record.pet.name}"
    Rails.logger.info "Breed: #{vaccination_record.pet.breed}"
    Rails.logger.info "Vaccination: #{vaccination_record.name}"
    Rails.logger.info "Vaccination Date: #{vaccination_record.vaccination_date}"
    Rails.logger.info "Expiry Date: #{vaccination_record.expiry_date}"
    Rails.logger.info "Status: EXPIRED"
    Rails.logger.info "=" * 60

    # In a real environment, we would use ActionMailer here
    # VaccinationMailer.expiration_notification(vaccination_record).deliver_later

    # We could also notify via other channels (SMS, push notifications, etc.)
    notify_via_webhook(vaccination_record) if webhook_configured?

    # Update a counter or timestamp for tracking
    vaccination_record.pet.update_column(:last_notification_sent_at, Time.current)
  end

  private

  def notify_via_webhook(vaccination_record)
    # Webhook integration example for scalability
    webhook_payload = {
      event: 'vaccination.expired',
      pet_id: vaccination_record.pet_id,
      vaccination_record_id: vaccination_record.id,
      pet_name: vaccination_record.pet.name,
      vaccination_name: vaccination_record.name,
      expiry_date: vaccination_record.expiry_date,
      timestamp: Time.current.iso8601
    }

    # In a real case, we would send to an external service
    Rails.logger.info "Webhook payload: #{webhook_payload.to_json}"
  end

  def webhook_configured?
    # Check if a webhook is configured in settings
    ENV['VACCINATION_WEBHOOK_URL'].present?
  end
end
