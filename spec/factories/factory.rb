FactoryBot.define do 
    factory :user do 
        # sequence(:id) { |n| n }
        name { Faker::Internet.unique.username }
        email { Faker::Internet.unique.email }
        password { 'Indore12345#' }
        phone { '7089332799' }
        otp { generate_otp }
    end
    factory :post do 
        title {Faker::Lorem.sentence}
        content {Faker::Lorem.paragraph}
        permission {%w[only_me my_friends everyone].sample}
        association :user
    end
end

def generate_otp 
    SecureRandom.random_number(100000..999999)
end