class Post < ApplicationRecord
    belongs_to :user
    belongs_to :stock

    validates :body, presence: true, length: { maximum: 3000 }
    validates :image_url, length: { maximum: 1000 }, allow_blank: true
end