require 'rails_helper'

def json 
    # puts response.body
    JSON.parse(response.body)
end

RSpec.describe "User", type: :request do 

    #   post '/signup', to:'users#signup'

    describe 'create a new user using /signup' do
        context 'with valid parameters' do 
            let!(:my_user) {FactoryBot.build(:user)}
            before do 
                post '/signup', params:
                {
                    name: my_user.name,
                    email: my_user.email,
                    password: my_user.password,
                    phone: my_user.phone 
                }
            end

            it 'returns a correct name, email, status' do 
                expect(json['name']).to eq(my_user.name)
                expect(json['email']).to eq(my_user.email)
                expect(response).to have_http_status(:created)
            end
        end

        context 'with duplicate email' do 
            let!(:my_user) {FactoryBot.build(:user)}
            before do 
                post '/signup'
                {
                    name: "Jasleen Kaur Khanuja",
                    email: my_user.email,
                    password: 'Indore12345#',
                    phone: '7089332799'
                }
            end

            it 'returns an error code' do 
                expect(response).to have_http_status(:unprocessable_entity)
            end
        end

        context 'with invalid parameters' do 
            let!(:my_user) {FactoryBot.build(:user)}
            
            before do 
                post '/signup', params:
                {
                    name: '',
                    email: '',
                    password: '',
                    phone: '' 
                }
            end

            it 'returns a name, password and email error' do 
                expect(json['error']).to include("Name can't be blank")
                expect(json['error']).to include("Password digest can't be blank")
                expect(json['error']).to include("Email can't be blank")
            end
        end
    end 

    # get '/index', to:'users#index'
    describe 'get the list of all the users' do 
        context 'getting correct numbers of users' do 
            FactoryBot.build_list(:user, 10)
            before do
                get '/index'
            end

            it 'returns correct number of users and a success http status' do 
                expect(json.size).to eq(30)
                expect(response).to have_http_status(:success)
            end
        end
    end

    describe 'user account verification' do
        context 'with valid token and existing user' do
          let!(:user) { FactoryBot.create(:user) }
          let(:token) { JsonWebToken.encode(user_id: user.id) }
      
          before do
            puts user.verification
            
            post "/verify", params: { token: token }
          end
      
          it 'verifies the user account and updates the verification status' do
            
            expect(json['message']).to eq("Account verified successfully")
            expect(response).to have_http_status(:success)
            
        end
      end
      

        context 'with invalid token' do 
            invalid_token = "onvalidtoken.iihijo.kubiubub"
            before do 
                post '/verify', params: {token:invalid_token}
            end

            it 'returns a message saying that the given token is invalid' do
                # expect(response).to have_http_status(:success)
                expect(json['message']).to eq("Invalid token")
            end
        end

        context 'with valid token but no user found' do
            let(:token) {JsonWebToken.encode(user_id: 900)}
            before do 
                post '/verify', params: {token: token}
                puts response.body
            end

            it 'returns a message saying user does not exist' do
                expect(json['message']).to eq("Entity not found")
            end
        end
    end

    describe 'refresh token when the access token has been expired' do 
    #     # post '/refresh', to: 'users#refresh'
        context 'with valid refresh token and valid user' do 
            let!(:user) {FactoryBot.create(:user)}
            let(:refresh_token) {JsonWebToken.encode(user_id: user.id, exp: 6.months.from_now)}

            before do
                post '/refresh', params: {refresh_token: refresh_token}
            end

            it 'returns a message saying new access token generated' do 
                expect(json['message']).to eq('New access token generated')
                expect(response).to have_http_status(200)
            end
        end

        context 'with invalid refresh token' do 
            invalid_refresh_token = "i.v.rt"
            before do
                post '/refresh', params: {refresh_token: invalid_refresh_token}
            end

            it 'returns a message saying invalid refresh token' do 
                expect(json['message']).to eq('Invalid refresh token or the refresh token is expired')
                expect(response).to have_http_status(:unprocessable_entity)
            end
        end
    end

    describe 'login the user' do 
    #     # post '/login', to:'users#login'
        context 'with valid parameters but the user is not verified' do 
            let!(:user) { FactoryBot.create(:user, verification: "false")}

            before do 
                
                post '/login', params:{
                    email: user.email,
                    password: user.password
                }
            end

            it 'returns a message to check the email for account verification' do

                expect(json['message']).to eq('Account not verified, please check your email for the verfication')
                expect(response).to have_http_status(:unprocessable_entity)
            end

        end

        context 'with valid parameters' do 
            let!(:user) { FactoryBot.create(:user)}

            before do 
                user.update(verification: true)
                post '/login', params:{
                    email: user.email,
                    password: user.password
                }
            end

            it 'returns a message user logged in successfully' do 
                expect(json['message']).to eq('user logged in successfully')
                expect(response).to have_http_status(:ok)
                expect(json).to have_key('access_token')
                expect(json).to have_key('refresh_token')
            end

        end

        context 'with unknown user or wrong password' do 
            let!(:user) { FactoryBot.create(:user)}

            before do 
                user.update(verification: true)
                post '/login', params:{
                    email: user.email,
                    password: '7089332799Jkk%'
                }
            end

            it 'returns a message user logged in successfully' do 
                expect(json['message']).to eq('Wrong password, or user does not exist')
                expect(response).to have_http_status(:unprocessable_entity)
            end
        end
    end

    describe "update user" do 
        let(:user) {FactoryBot.create(:user, verification: "true")}
        let(:access_token) {JsonWebToken.encode(user_id: user.id)}
        let(:expired_access_token) {JsonWebToken.encode({user_id: user.id}, Time.now.to_i - 1)}
        let(:profile_picture) {fixture_file_upload('profile_picture.jpeg', 'img/jpg')}
        let(:cover_picture) {fixture_file_upload('cover_picture.jpeg', 'img/jpg')}

        context "when the token is valid" do 
            #   patch '/update', to:'users#update'

            it 'updates the user' do 
                patch '/update', params: { name: 'JK130624' }, headers: {'Authorization'=>"Bearer #{access_token}"}
                expect(json['user']['name']).to eq('JK130624')
                
                expect(response).to have_http_status(:ok)
            end

            it 'updates the profile picture and cover picture' do 
                patch '/update', params: 
                {
                    name: 'JK241306',
                    profile_picture: profile_picture,
                    cover_picture: cover_picture
                }, headers: {'Authorization'=>"Bearer#{access_token}"}
                expect(user.profile_picture).to be_present
                expect(user.cover_picture).to be_present
                expect(response).to have_http_status(:ok)
            end

        end
        context 'with expired token' do 

            it 'returns unauthorized' do
                patch '/update', params: {}, headers: {'Authorization' => "Bearer#{expired_access_token}"}
                # byebug
                expect(json['error']).to eq("Unauthorized user")
                expect(response).to have_http_status(:unauthorized)
            end
        end
    end
    describe 'Show the current user' do 
        # get '/show', to:'users#show'
        let(:user) {FactoryBot.create(:user, verification: "true")}
        let(:access_token) {JsonWebToken.encode(user_id: user.id)}

        it 'Gives details of the current user' do 
            get '/show', headers: {'Authorization'=>"Bearer #{access_token}"}
            expect(json['user']['name']).to eq(user.name)
            expect(json['user']['email']).to eq(user.email)
            expect(response).to have_http_status(:ok)
        end
    end

    describe 'Deletes the user' do 
        let(:user) {FactoryBot.create(:user, verification: "true")}
        let(:access_token) {JsonWebToken.encode(user_id: user.id)}
        # delete '/delete', to:'users#delete'
        it 'returns User is deleted' do 
            delete '/delete', headers:{'Authorization'=>"Bearer #{access_token}"}
            expect(json['message']).to eq("User is deleted")
        end
    end
end