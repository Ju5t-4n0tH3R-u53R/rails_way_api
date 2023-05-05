class CreateAlbums < ActiveRecord::Migration[7.0]
  def change
    create_table :albums do |t|
      t.string 'title'
      t.string 'performer'
      t.integer 'cost'
      t.datetime 'last_purchased_at'
      t.integer 'last_purchased_by'
      t.timestamps
    end
  end
end
