class CreateTrophies < ActiveRecord::Migration
  def change
    create_table :trophies do |t|
      t.integer :user_id
      t.string :work_id

      t.timestamps null: false
    end
  end
end
