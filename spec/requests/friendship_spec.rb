require 'rails_helper'

def json 
    JSON.parse(response.body)
end
RSpec.describe "Friendship", type: :request do
    describe 'creates a new friendhip' do 
        let(:my_user) {FactoryBot.create(:user, verification: "true")}
        let(:access_token) {JsonWebToken.encode(user_id: my_user.id)}
        let(:my_friend1) {FactoryBot.create(:user, verification: "true")}
        let(:my_friend2) {FactoryBot.create(:user, verification: "true")}
        let(:my_friend3) {FactoryBot.create(:user, verification: "true")}
        let(:my_friend4) {FactoryBot.create(:user, verification: "true")}
        let!(:friendship1) {Friendship.create(sender_id: my_user.id, reciever_id: my_friend1.id, status:"pending")}
        let!(:friendship2) {Friendship.create(sender_id: my_user.id, reciever_id: my_friend2.id, status:"accepted")}
        let!(:friendship3) {Friendship.create(sender_id: my_user.id, reciever_id: my_friend3.id, status:"declined", created_at: Time.now - 31.days)}
        let!(:friendship4) {Friendship.create(sender_id: my_user.id, reciever_id: my_friend4.id, status:"declined", created_at: Time.now - 20.days)}
        let(:my_friend5) {FactoryBot.create(:user, verification: "true")}
        let(:my_friend6) {FactoryBot.create(:user, verification: "true")}
        let!(:my_blocked) {Block.create(blocker_id: my_user.id, blocked_id: my_friend5.id)}

        it 'return already friends' do 
            post "/create_friend", params:{ id: my_friend2.id}, headers:{'Authorization'=>"Bearer #{access_token}"}
            expect(json['message']).to eq("Already friends")
        end

        it 'returns Friend request already in queue' do 
            post "/create_friend", params:{ id: my_friend1.id}, headers:{'Authorization'=>"Bearer #{access_token}"}
            expect(json['message']).to eq("Friend request already in queue")
        end

        it "return Friend request not sent(cool off period)" do 
            post "/create_friend", params:{ id: my_friend4.id}, headers:{'Authorization'=>"Bearer #{access_token}"}
            expect(json['message']).to eq("Friend request not sent(cool off period)")
        end

        it "returns  Friend request sent when cool off period is completed" do 
            post "/create_friend", params:{ id: my_friend3.id}, headers:{'Authorization'=>"Bearer #{access_token}"}
            expect(json['message']).to eq("Friend request sent")
        end

        it 'returns Friend request cannot be sent' do 
            post "/create_friend", params:{ id: my_friend5.id}, headers:{'Authorization'=>"Bearer #{access_token}"}
            expect(json['message']).to eq("Friend request cannot be sent")
        end
        it 'returns Friend request send for new friendship' do 
            post "/create_friend", params:{ id: my_friend6.id}, headers:{'Authorization'=>"Bearer #{access_token}"}
            expect(json['message']).to eq("Friend request send")
        end

    end
end
