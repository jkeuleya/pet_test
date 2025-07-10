class VaccinationRecordSerializer < ActiveModel::Serializer
  attributes :id, :name, :vaccination_date, :expiry_date, :expired,
             :days_until_expiry, :expiring_soon, :created_at, :updated_at

  belongs_to :pet, if: :include_pet?

  def expiring_soon
    object.expiring_soon?
  end

  def include_pet?
    @instance_options[:include_pet] ||
      @instance_options[:include]&.include?(:pet)
  end
end
