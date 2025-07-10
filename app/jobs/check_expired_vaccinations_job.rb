class CheckExpiredVaccinationsJob < ApplicationJob
  queue_as :low

  def perform
    Rails.logger.info "Starting daily check for expired vaccinations..."

    # Mark all expired vaccinations
    expired_count = VaccinationRecord.mark_expired_records

    Rails.logger.info "Marked #{expired_count} vaccination records as expired"

    # Optional: Send daily report
    if expired_count > 0
      send_daily_report(expired_count)
    end
  end

  private

  def send_daily_report(count)
    Rails.logger.info "=" * 60
    Rails.logger.info "DAILY VACCINATION EXPIRATION REPORT"
    Rails.logger.info "Date: #{Date.current}"
    Rails.logger.info "Total expired today: #{count}"
    Rails.logger.info "=" * 60

    # In a real case, we could send a summary email
    # AdminMailer.daily_expiration_report(count).deliver_later
  end
end
