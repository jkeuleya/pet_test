class CreateVaccinationRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :vaccination_records do |t|
      t.references :pet, null: false, foreign_key: true
      t.string :name, null: false
      t.date :vaccination_date, null: false
      t.date :expiry_date, null: false
      t.boolean :expired, default: false, null: false

      t.timestamps
    end

    add_index :vaccination_records, :expired
    add_index :vaccination_records, :expiry_date
    add_index :vaccination_records, [:pet_id, :expired]
  end
end
