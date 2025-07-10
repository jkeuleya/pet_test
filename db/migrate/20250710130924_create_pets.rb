class CreatePets < ActiveRecord::Migration[7.2]
  def change
    create_table :pets do |t|
      t.string :name, null: false
      t.string :breed, null: false
      t.integer :age, null: false

      t.timestamps
    end

    add_index :pets, :name
    add_index :pets, :breed
  end
end
