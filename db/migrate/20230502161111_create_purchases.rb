class CreatePurchases < ActiveRecord::Migration[7.0]
  def change
    create_table :purchases do |t|
      t.integer "user_id"
      t.integer "album_id"
      t.timestamps
    end
  end
end
