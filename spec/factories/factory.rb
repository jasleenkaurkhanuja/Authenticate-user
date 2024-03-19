FactoryBot.define do 
    factory :user do 
        # sequence(:id) { |n| n }
        name { Faker::Internet.unique.username }
        email { Faker::Internet.unique.email }
        password { 'Indore12345#' }
        phone { '7089332799' }
    end
    factory :post do 
        title {Faker::Lorem.sentence}
        content {Faker::Lorem.paragraph}
        permission {%w[only_me my_friends everyone].sample}
        association :user
    end
end