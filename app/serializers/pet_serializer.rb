# Optimized serializer with performance considerations
class PetSerializer < ActiveModel::Serializer
  attributes :id, :name, :breed, :age, :age_category,
             :has_expired_vaccinations, :created_at, :updated_at

  # Yeah I know, can be heavy, we can remove it, just had fun here :D
  attribute :vaccination_summary do
    {
      total: vaccination_records_count,
      expired: expired_vaccinations_count,
      active: active_vaccinations_count,
      expiring_soon: expiring_soon_count
    }
  end

  # Here too
  attribute :upcoming_expirations do
    object.upcoming_vaccination_expirations(30).limit(3).map do |record|
      {
        id: record.id,
        name: record.name,
        expiry_date: record.expiry_date,
        days_until_expiry: record.days_until_expiry
      }
    end
  end

  has_many :vaccination_records, if: :include_vaccination_records?

  def has_expired_vaccinations
    object.has_expired_vaccinations?
  end

  def include_vaccination_records?
    @instance_options[:include_vaccination_records] ||
      @instance_options[:include]&.include?(:vaccination_records)
  end

  private

  # Use association counts to avoid N+1 queries
  def vaccination_records_count
    object.vaccination_records.size
  end

  def expired_vaccinations_count
    object.vaccination_records.select(&:expired?).size
  end

  def active_vaccinations_count
    object.vaccination_records.reject(&:expired?).size
  end

  def expiring_soon_count
    object.vaccination_records.select { |r| !r.expired? && r.expiring_soon? }.size
  end
end
