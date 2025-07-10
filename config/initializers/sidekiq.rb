# Sidekiq configuration - All in one place
require 'sidekiq'
require 'sidekiq/web'

# Redis configuration from sidekiq.yml or ENV
redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

  # Load sidekiq-cron jobs
  if defined?(Sidekiq::Cron)
    require 'sidekiq-cron'

    # Define cron jobs
    Sidekiq::Cron::Job.create(
      name: 'Check Expired Vaccinations',
      cron: '0 9 * * *',  # Every day at 9am
      class: 'CheckExpiredVaccinationsJob',
      queue: 'low'
    )

    Rails.logger.info "Sidekiq-cron jobs loaded"
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

# Default job options
Sidekiq.default_job_options = {
  'backtrace' => true,
  'retry' => 3
}
