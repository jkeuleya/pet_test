# Seeds for testing Pet Vaccination API

puts "🧹 Cleaning database..."
VaccinationRecord.destroy_all
Pet.destroy_all

puts "🐾 Creating pets..."

# Create 20 pets with varied data
pets_data = [
  { name: "Max", breed: "Labrador", age: 3 },
  { name: "Luna", breed: "Siamese Cat", age: 2 },
  { name: "Charlie", breed: "Golden Retriever", age: 5 },
  { name: "Bella", breed: "Persian Cat", age: 4 },
  { name: "Rocky", breed: "German Shepherd", age: 7 },
  { name: "Milo", breed: "British Shorthair", age: 1 },
  { name: "Cooper", breed: "Beagle", age: 6 },
  { name: "Lucy", breed: "Maine Coon", age: 8 },
  { name: "Bailey", breed: "Bulldog", age: 4 },
  { name: "Daisy", breed: "Ragdoll Cat", age: 3 },
  { name: "Duke", breed: "Poodle", age: 9 },
  { name: "Oliver", breed: "Scottish Fold", age: 2 },
  { name: "Zeus", breed: "Rottweiler", age: 5 },
  { name: "Chloe", breed: "Bengal Cat", age: 3 },
  { name: "Jack", breed: "Yorkshire Terrier", age: 10 },
  { name: "Sophie", breed: "Russian Blue", age: 6 },
  { name: "Toby", breed: "Cocker Spaniel", age: 4 },
  { name: "Lily", breed: "Sphynx Cat", age: 2 },
  { name: "Oscar", breed: "Dachshund", age: 7 },
  { name: "Simba", breed: "Abyssinian Cat", age: 5 }
]

pets = pets_data.map do |pet_data|
  Pet.create!(pet_data)
end

puts "✅ #{pets.count} pets created"

puts "💉 Creating vaccination records..."

vaccination_types = [
  { name: "Rage Vaccine", validity_months: 12 },
  { name: "DHPP Vaccine", validity_months: 12 },
  { name: "Bordetella", validity_months: 6 },
  { name: "Lyme Disease", validity_months: 12 },
  { name: "Feline Leukemia", validity_months: 12 },
  { name: "FVRCP Vaccine", validity_months: 12 },
  { name: "Rabies Booster", validity_months: 36 }
]

vaccination_count = 0

pets.each do |pet|
  # Each pet has between 1 and 4 vaccinations
  rand(1..4).times do
    vaccine = vaccination_types.sample

    # Random vaccination date within the last 2 years
    days_ago = rand(0..730) # 0 to 2 years (730 days)
    vaccination_date = Date.current - days_ago.days
    expiry_date = vaccination_date + vaccine[:validity_months].months

    # Some vaccinations are already expired
    expired = expiry_date < Date.current

    VaccinationRecord.create!(
      pet: pet,
      name: vaccine[:name],
      vaccination_date: vaccination_date,
      expiry_date: expiry_date,
      expired: expired
    )

    vaccination_count += 1
  end
end

puts "✅ #{vaccination_count} vaccination records created"

# Statistics
expired_count = VaccinationRecord.where(expired: true).count
expiring_soon = VaccinationRecord.expiring_soon.count

puts "\n📊 Statistics:"
puts "- Expired vaccinations: #{expired_count}"
puts "- Vaccinations expiring in the next 30 days: #{expiring_soon}"
puts "- Pets with expired vaccinations: #{Pet.joins(:vaccination_records).where(vaccination_records: { expired: true }).distinct.count}"

puts "\n✨ Seeds completed successfully!"
