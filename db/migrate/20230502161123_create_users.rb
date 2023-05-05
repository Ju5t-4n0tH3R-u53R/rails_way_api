class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string "name", null: false
      t.string "email", null: false
      t.string "password_digest"
      t.integer "total_purchases", default: 0, null: false
      t.string "auth_token", index: { unique: true }
      t.timestamps
    end
  end
end
