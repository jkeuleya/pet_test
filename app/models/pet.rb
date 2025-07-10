class Pet < ApplicationRecord
  # Associations
  has_many :vaccination_records, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :breed, presence: true, length: { minimum: 2, maximum: 100 }
  validates :age, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 30
  }

  # Scopes - optimized for database indexes
  scope :young, -> { where('age < ?', 2) }
  scope :adult, -> { where('age >= ? AND age < ?', 2, 8) }
  scope :senior, -> { where('age >= ?', 8) }
  scope :by_breed, ->(breed) { where('LOWER(breed) = LOWER(?)', breed) }

  # Avoid us using DISTINCT as it can be expensive on large datasets
  scope :with_expired_vaccinations, -> {
    where('EXISTS (SELECT 1 FROM vaccination_records WHERE vaccination_records.pet_id = pets.id AND vaccination_records.expired = true)')
  }

  scope :without_expired_vaccinations, -> {
    where('NOT EXISTS (SELECT 1 FROM vaccination_records WHERE vaccination_records.pet_id = pets.id AND vaccination_records.expired = true)')
  }

  # Instance methods
  def age_category
    case age
    when 0..1 then 'puppy/kitten'
    when 2..7 then 'adult'
    else 'senior'
    end
  end

  def has_expired_vaccinations?
    vaccination_records.expired.exists?
  end

  def upcoming_vaccination_expirations(days = 30)
    vaccination_records
      .active
      .expiring_soon(days)
      .order(expiry_date: :asc)
  end
end
