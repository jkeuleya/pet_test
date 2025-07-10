class PetSerializer < ActiveModel::Serializer
  attributes :id, :name, :breed, :age, :age_category,
             :has_expired_vaccinations, :created_at, :updated_at

  has_many :vaccination_records, if: :include_vaccination_records?

  def has_expired_vaccinations
    object.has_expired_vaccinations?
  end

  def include_vaccination_records?
    @instance_options[:include_vaccination_records] ||
    @instance_options[:include] && @instance_options[:include].include?(:vaccination_records)
  end
end
