class ChangeTableName < ActiveRecord::Migration[5.0]
  def change
     rename_table :sufia_features, :hyrax_features
  end
end
