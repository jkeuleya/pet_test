class PetSerializer < ActiveModel::Serializer
  attributes :id, :name, :breed, :age, :age_category,
             :created_at, :updated_at
end
