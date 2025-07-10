class VaccinationRecord < ApplicationRecord
  # Associations
  belongs_to :pet

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :vaccination_date, presence: true
  validates :expiry_date, presence: true
  validate :expiry_date_after_vaccination_date

  # Callbacks
  before_save :check_if_expired

  # Scopes
  scope :expired, -> { where(expired: true) }
  scope :active, -> { where(expired: false) }
  scope :expiring_soon, ->(days = 30) {
    active.where('expiry_date <= ?', days.days.from_now)
  }
  scope :by_pet, ->(pet_id) { where(pet_id: pet_id) }

  # Class methods
  def self.mark_expired_records
    where('expiry_date < ? AND expired = ?', Date.current, false)
      .update_all(expired: true)
  end

  # Instance methods
  def days_until_expiry
    return 0 if expired?
    (expiry_date - Date.current).to_i
  end

  def expiring_soon?(days = 30)
    !expired? && days_until_expiry <= days
  end

  def mark_as_expired!
    update!(expired: true)
  end

  private

  def expiry_date_after_vaccination_date
    return unless vaccination_date && expiry_date

    if expiry_date <= vaccination_date
      errors.add(:expiry_date, 'must be after vaccination date')
    end
  end

  def check_if_expired
    self.expired = true if expiry_date && expiry_date < Date.current
  end
end
