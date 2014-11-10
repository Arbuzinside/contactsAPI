class CreateControllingers < ActiveRecord::Migration
  def change
    create_table :controllingers do |t|
      t.string :name
      t.integer :age

      t.timestamps
    end
  end
end
