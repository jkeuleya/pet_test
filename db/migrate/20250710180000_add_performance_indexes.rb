class AddPerformanceIndexes < ActiveRecord::Migration[7.2]
  def change
    # Composite index for filtering pets by breed and age
    add_index :pets, [:breed, :age], name: 'index_pets_on_breed_and_age'

    # Index for filtering vaccination records by expiry status and date
    add_index :vaccination_records, [:expired, :expiry_date], name: 'index_vaccination_records_on_expired_and_expiry_date'

    # Index for finding vaccination records by pet and expiry date (for upcoming expirations)
    add_index :vaccination_records, [:pet_id, :expiry_date], name: 'index_vaccination_records_on_pet_id_and_expiry_date'

    # Index for vaccination date queries
    add_index :vaccination_records, :vaccination_date, name: 'index_vaccination_records_on_vaccination_date'

    # Index for last notification timestamp (for notification throttling)
    add_index :pets, :last_notification_sent_at, name: 'index_pets_on_last_notification_sent_at'
  end
end
