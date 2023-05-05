class Purchase < ApplicationRecord
  belongs_to :album
  belongs_to :user

  validates :album, :user, presence: true, on: %i[create update]

  after_save do |purchase|
    add_last_purchased_data_to_album(purchase)
    user_total_purchases(purchase)
  end

  def add_last_purchased_data_to_album(purchase)
    purchase.album.last_purchased_at = purchase.created_at
    purchase.album.last_purchased_by = purchase.user_id
    purchase.album.save!
  end

  def user_total_purchases(purchase)
    purchase.user.total_purchases += 1
    purchase.user.save!
  end
end
