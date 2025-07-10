require 'rails_helper'

RSpec.describe VaccinationRecord, type: :model do
  describe 'associations' do
    it { should belong_to(:pet) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(100) }
    it { should validate_presence_of(:vaccination_date) }
    it { should validate_presence_of(:expiry_date) }

    describe 'custom validations' do
      let(:pet) { create(:pet) }

      it 'validates expiry_date is after vaccination_date' do
        record = build(:vaccination_record,
                       pet: pet,
                       vaccination_date: Date.current,
                       expiry_date: Date.current - 1.day)

        expect(record).not_to be_valid
        expect(record.errors[:expiry_date]).to include('must be after vaccination date')
      end

      it 'allows expiry_date after vaccination_date' do
        record = build(:vaccination_record,
                       pet: pet,
                       vaccination_date: Date.current,
                       expiry_date: Date.current + 1.year)

        expect(record).to be_valid
      end
    end
  end

  describe 'callbacks' do
    describe 'before_save' do
      it 'sets expired to true if expiry_date is in the past' do
        record = create(:vaccination_record,
                        vaccination_date: 2.years.ago,
                        expiry_date: 1.year.ago,
                        expired: false)

        expect(record.expired).to be true
      end

      it 'keeps expired as false if expiry_date is in the future' do
        record = create(:vaccination_record,
                        vaccination_date: Date.current,
                        expiry_date: 1.year.from_now,
                        expired: false)

        expect(record.expired).to be false
      end
    end

    describe 'after_update' do
      it 'triggers VaccinationExpirationJob when marked as expired' do
        record = create(:vaccination_record, expired: false)

        expect {
          record.update!(expired: true)
        }.to have_enqueued_job(VaccinationExpirationJob).with(record)
      end

      it 'does not trigger job when other attributes change' do
        record = create(:vaccination_record, expired: false)

        expect {
          record.update!(name: 'Updated Vaccine')
        }.not_to have_enqueued_job(VaccinationExpirationJob)
      end
    end
  end

  describe 'scopes' do
    let!(:expired_record) { create(:vaccination_record, expired: true) }
    let!(:active_record) { create(:vaccination_record, expired: false) }

    describe '.expired' do
      it 'returns only expired records' do
        expect(VaccinationRecord.expired).to include(expired_record)
        expect(VaccinationRecord.expired).not_to include(active_record)
      end
    end

    describe '.active' do
      it 'returns only active records' do
        expect(VaccinationRecord.active).to include(active_record)
        expect(VaccinationRecord.active).not_to include(expired_record)
      end
    end

    describe '.expiring_soon' do
      let!(:expiring_soon) { create(:vaccination_record, expired: false, expiry_date: 10.days.from_now) }
      let!(:expiring_later) { create(:vaccination_record, expired: false, expiry_date: 60.days.from_now) }

      it 'returns records expiring within specified days' do
        results = VaccinationRecord.expiring_soon(30)
        expect(results).to include(expiring_soon)
        expect(results).not_to include(expiring_later, expired_record)
      end
    end

    describe '.by_pet' do
      let(:pet1) { create(:pet) }
      let(:pet2) { create(:pet) }
      let!(:record1) { create(:vaccination_record, pet: pet1) }
      let!(:record2) { create(:vaccination_record, pet: pet2) }

      it 'returns records for specified pet' do
        expect(VaccinationRecord.by_pet(pet1.id)).to include(record1)
        expect(VaccinationRecord.by_pet(pet1.id)).not_to include(record2)
      end
    end
  end

  describe 'class methods' do
    describe '.mark_expired_records' do
      let!(:should_expire) do
        # Create with future date first to bypass the before_save callback
        record = create(:vaccination_record,
                        vaccination_date: 2.years.ago,
                        expiry_date: 1.day.from_now,
                        expired: false)
        # Then update the expiry_date directly in the database
        record.update_column(:expiry_date, 1.day.ago)
        record
      end
      let!(:already_expired) { create(:vaccination_record, expiry_date: 1.day.ago, expired: true) }
      let!(:not_expired) { create(:vaccination_record, expiry_date: 1.day.from_now, expired: false) }

      it 'marks records with past expiry dates as expired' do
        expect {
          VaccinationRecord.mark_expired_records
        }.to change { should_expire.reload.expired }.from(false).to(true)
      end

      it 'does not affect already expired records' do
        expect {
          VaccinationRecord.mark_expired_records
        }.not_to(change { already_expired.reload.expired })
      end

      it 'does not affect records with future expiry dates' do
        expect {
          VaccinationRecord.mark_expired_records
        }.not_to(change { not_expired.reload.expired })
      end
    end
  end

  describe 'instance methods' do
    describe '#days_until_expiry' do
      it 'returns 0 for expired records' do
        record = build(:vaccination_record, expired: true, expiry_date: 10.days.from_now)
        expect(record.days_until_expiry).to eq(0)
      end

      it 'returns correct days for active records' do
        record = build(:vaccination_record, expired: false, expiry_date: 10.days.from_now)
        expect(record.days_until_expiry).to eq(10)
      end
    end

    describe '#expiring_soon?' do
      let(:record) { build(:vaccination_record, expired: false) }

      it 'returns true if expiring within specified days' do
        record.expiry_date = 10.days.from_now
        expect(record.expiring_soon?(30)).to be true
      end

      it 'returns false if expiring after specified days' do
        record.expiry_date = 40.days.from_now
        expect(record.expiring_soon?(30)).to be false
      end

      it 'returns false if already expired' do
        record.expired = true
        record.expiry_date = 10.days.from_now
        expect(record.expiring_soon?(30)).to be false
      end
    end

    describe '#mark_as_expired!' do
      let(:record) { create(:vaccination_record, expired: false) }

      it 'updates expired to true' do
        expect {
          record.mark_as_expired!
        }.to change { record.expired }.from(false).to(true)
      end

      it 'persists the change' do
        record.mark_as_expired!
        expect(record.reload.expired).to be true
      end
    end
  end
end
