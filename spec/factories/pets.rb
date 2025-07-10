FactoryBot.define do
  factory :pet do
    name { Faker::Creature::Dog.name }
    breed { ['Labrador', 'Golden Retriever', 'German Shepherd', 'Beagle', 'Poodle', 'Siamese Cat', 'Persian Cat', 'Maine Coon'].sample }
    age { rand(1..15) }

    trait :young do
      age { rand(0..1) }
    end

    trait :adult do
      age { rand(2..7) }
    end

    trait :senior do
      age { rand(8..15) }
    end

    trait :with_vaccinations do
      after(:create) do |pet|
        create_list(:vaccination_record, 3, pet: pet)
      end
    end

    trait :with_expired_vaccinations do
      after(:create) do |pet|
        create(:vaccination_record, :expired, pet: pet)
        create(:vaccination_record, :active, pet: pet)
      end
    end
  end
end
