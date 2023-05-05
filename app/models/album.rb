class Album < ApplicationRecord
    has_many :purchases
    
    validates :title, :performer, :cost, presence: true, on: [:create, :update]
    validates :cost, numericality: { greater_than: 0 }
  end
  