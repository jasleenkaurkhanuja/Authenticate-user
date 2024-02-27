class User < ApplicationRecord
    has_secure_password
    has_many :posts, dependent: :destroy
    has_many :likes, dependent: :destroy
    has_many :comments, dependent: :destroy

    has_many :sent_friendships, class_name: 'Friendship', foreign_key: 'sender_id', dependent: :destroy
    has_many :recieved_friendships, class_name: 'Friendship', foreign_key: 'reciever_id', dependent: :destroy


    has_many :sent_notifications, class_name: 'Notification', foreign_key: 'sender_id', dependent: :destroy
    has_many :recieved_notifications, class_name: 'Notification', foreign_key: 'reciever_id',dependent: :destroy
    
    validates :email, presence: true, uniqueness: true 
    validates :name, presence: true
    
    validates :password_digest, presence: true, length: {minimum: 8}, format: { with: /\A(?=.*[A-Z])(?=.*[a-z])(?=.*\W)/, message: "The password should atleast 8 characters with a lower case letter, un upper case letter and a special character"}
    
    validates :phone, presence: true, length: { is:10 }, numericality: { only_integer: true }
end


# request.host