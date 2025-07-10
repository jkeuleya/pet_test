require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe VaccinationExpirationJob, type: :job do
  let(:vaccination_record) { create(:vaccination_record, :expired) }

  describe '#perform' do
    it 'logs vaccination expiration notification' do
      expect(Rails.logger).to receive(:info).at_least(:once)

      VaccinationExpirationJob.new.perform(vaccination_record.id)
    end

    it 'handles non-existent vaccination records gracefully' do
      expect {
        VaccinationExpirationJob.new.perform(999999)
      }.not_to raise_error
    end

    it 'updates pet last_notification_sent_at timestamp' do
      pet = vaccination_record.pet
      expect {
        VaccinationExpirationJob.new.perform(vaccination_record.id)
      }.to change { pet.reload.last_notification_sent_at }
    end

    context 'with webhook configured' do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('VACCINATION_WEBHOOK_URL').and_return('https://example.com/webhook')
      end

      it 'logs webhook payload' do
        expect(Rails.logger).to receive(:info).with(/Webhook payload:/).at_least(:once)
        expect(Rails.logger).to receive(:info).at_least(:once)

        VaccinationExpirationJob.new.perform(vaccination_record.id)
      end
    end
  end

  describe 'Sidekiq integration' do
    it 'enqueues job in default queue' do
      Sidekiq::Testing.fake! do
        VaccinationExpirationJob.perform_later(vaccination_record)

        expect(ActiveJob::Base.queue_adapter.enqueued_jobs.size).to eq(1)
        expect(ActiveJob::Base.queue_adapter.enqueued_jobs.first['queue_name']).to eq('default')
      end
    end

    it 'can be performed inline' do
      Sidekiq::Testing.inline! do
        expect(Rails.logger).to receive(:info).at_least(:once)

        VaccinationExpirationJob.perform_later(vaccination_record)
      end
    end
  end

  describe 'retry configuration' do
    it 'has correct retry settings' do
      job = VaccinationExpirationJob.new
      options = job.class.sidekiq_options

      expect(options['retry']).to eq(3)
      expect(options['dead']).to eq(false)
    end
  end
end
