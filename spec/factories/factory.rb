FactoryBot.define do 
    factory :user do 
        # sequence(:id) { |n| n }
        name { Faker::Internet.unique.username }
        email { Faker::Internet.unique.email }
        password { 'Indore12345#' }
        phone { '7089332799' }
    end
end