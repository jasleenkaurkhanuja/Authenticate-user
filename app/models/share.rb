class Share < ApplicationRecord
    belongs_to :original, class_name: 'User', foreign_key: 'original_id'
    belongs_to :sharer, class_name: 'User', foreign_key: 'user_id'
    belongs_to :post, class_name: 'Post', foreign_key: 'post_id'
end
