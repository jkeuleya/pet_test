FactoryBot.define do
  factory :vaccination_record do
    association :pet
    name { ["Rage Vaccine", "DHPP Vaccine", "Bordetella", "Lyme Disease", "Feline Leukemia", "FVRCP Vaccine"].sample }
    vaccination_date { Faker::Date.between(from: 1.year.ago, to: Date.current) }
    expiry_date { vaccination_date + 1.year }
    expired { false }

    trait :expired do
      vaccination_date { 2.years.ago }
      expiry_date { 1.year.ago }
      expired { true }
    end

    trait :active do
      vaccination_date { 6.months.ago }
      expiry_date { 6.months.from_now }
      expired { false }
    end

    trait :expiring_soon do
      vaccination_date { 11.months.ago }
      expiry_date { 1.month.from_now }
      expired { false }
    end

    trait :recently_vaccinated do
      vaccination_date { 1.week.ago }
      expiry_date { 1.year.from_now - 1.week }
      expired { false }
    end
  end
end
