class User < ApplicationRecord
    has_secure_password
    validates :email, presence: true, uniqueness: true 
    validates :name, presence: true
    validates :password_digest, presence: true, length: {minimum: 8}, format: { with: /\A(?=.*[A-Z])(?=.*[a-z])(?=.*\W)/, message: "The password should atleast 8 characters with a lower case letter, un upper case letter and a special character"}
    
    validates :phone, presence: true, length: { is:10 }, numericality: { only_integer: true }
end
