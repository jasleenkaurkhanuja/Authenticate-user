class Post < ApplicationRecord
  belongs_to :user
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :shares, class_name: 'Share', foreign_key: 'post_id', dependent: :destroy
  validates :title, presence:true 
  validates :content, presence:true
end
