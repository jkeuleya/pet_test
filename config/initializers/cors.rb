# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # In development, accept all origins
    if Rails.env.development?
      origins '*'
    else
      # In production, limit to allowed domains
      origins ENV.fetch('ALLOWED_ORIGINS', '').split(',')
    end

    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['X-Total-Count', 'X-Page', 'X-Per-Page'],
      max_age: 86400
  end
end
