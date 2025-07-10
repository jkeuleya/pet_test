require 'socket'
require 'etc'

module Api
  module V1
    class HealthController < ApplicationController
      def index
        render json: health_status
      end

      private

      def health_status
        {
          status: overall_status,
          timestamp: Time.current.iso8601,
          services: {
            database: check_database,
            redis: check_redis,
            sidekiq: check_sidekiq
          }
        }
      end

      def overall_status
        checks = [check_database[:status], check_redis[:status], check_sidekiq[:status]]

        if checks.all? { |status| status == 'healthy' }
          'healthy'
        elsif checks.any? { |status| status == 'unhealthy' }
          'unhealthy'
        else
          'degraded'
        end
      end

      def check_database
        ActiveRecord::Base.connection.execute('SELECT 1')
        { status: 'healthy', response_time: measure_time { Pet.first } }
      rescue => e
        { status: 'unhealthy', error: e.message }
      end

      def check_redis
        redis = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))
        start_time = Time.current
        redis.ping

        {
          status: 'healthy',
          response_time: "#{((Time.current - start_time) * 1000).round(2)}ms"
        }
      rescue => e
        { status: 'unhealthy', error: e.message }
      end

      def check_sidekiq
        processes = Sidekiq::ProcessSet.new

        {
          status: processes.size > 0 ? 'healthy' : 'unhealthy',
          processes: processes.size
        }
      rescue => e
        { status: 'unhealthy', error: e.message }
      end

      def measure_time
        start_time = Time.current
        yield
        "#{((Time.current - start_time) * 1000).round(2)}ms"
      end
    end
  end
end
