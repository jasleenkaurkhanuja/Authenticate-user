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

            it 'returns a correct name' do 
                expect(json['name']).to eq(my_user.name)
            end

            it 'returns a correct email' do 
                expect(json['email']).to eq(my_user.email)
            end

            it 'returns a correct status' do 
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

            it 'returns a name error' do 
                expect(json['error']).to include("Name can't be blank")
            end

            it 'returns a password error' do 
                expect(json['error']).to include("Password digest can't be blank")
            end

            it 'returns an email error' do 
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

            it 'returns correct number of users' do 
                expect(json.size).to eq(20)
            end

            it 'returns a correct response status' do 
                expect(response).to have_http_status(:success)
            end
        end
    end

    describe 'user account verification' do
        context 'with valid token and existing user' do
          let!(:user) { FactoryBot.create(:user) }
          let(:token) { JsonWebToken.encode(user_id: user.id) }
      
          before do
            # Stub JsonWebToken.decode to return the decoded token
            user.update(token: token)
            puts user.verification
            allow(JsonWebToken).to receive(:decode).with(token).and_return({ "user_id" => user.id })
            
            post "/verify", params: { token: token }
          end
      
          it 'verifies the user account and updates the verification status' do
            
            expect(response).to have_http_status(:success)
            expect(json['message']).to eq("Account verified successfully")
        end
      end
      

        context 'with invalid token' do 
            invalid_token = "onvalidtoken.iihijo.kubiubub"
            before do 
                allow(JsonWebToken).to receive(:decode).with(invalid_token).and_return(nil)
                post '/verify', params: {token:invalid_token}
            end

            it 'returns a message saying that the given token is invalid' do
                # expect(response).to have_http_status(:success)
                expect(json['message']).to eq("decoded not present")
            end
        end

        context 'with valid token but no user found' do
            let(:token) {JsonWebToken.encode(user_id: 900)}
            before do 
                allow(JsonWebToken).to receive(:decode).with(token).and_return({"user_id" => 900})
                allow(User).to receive(:find).with(900).and_return(nil)
                post '/verify', params: {token: token}
            end

            it 'returns a message saying account not verified' do
                expect(json['message']).to eq("Account not verified")
            end
        end
    end

    describe 'refresh token when the access token has been expired' do 
        # post '/refresh', to: 'users#refresh'
        context 'with valid refresh token and valid user' do 
            let!(:user) {FactoryBot.create(:user)}
            let(:refresh_token) {JsonWebToken.encode(user_id: user.id, exp: 6.months.from_now.to_i)}

            before do
                allow(JsonWebToken).to receive(:decode).with(refresh_token).and_return("user_id" => user.id, "exp" => 6.months.from_now.to_i)
                post '/refresh', params: {refresh_token: refresh_token}
            end

            it 'returns a message saying new access token generated' do 
                expect(json['message']).to eq('New access token generated')
                expect(response).to have_http_status(200)
            end
        end

        context 'with expired refresh token and valid user' do 
            let!(:user) {FactoryBot.create(:user)}
            let(:refresh_token) {JsonWebToken.encode(user_id: user.id, exp: Time.now.to_i - 7000)}

            before do
                puts user
                allow(JsonWebToken).to receive(:decode).with(refresh_token).and_return("user_id" => user.id, "exp" => Time.now.to_i - 7000)
                post '/refresh', params: {refresh_token: refresh_token}
            end

            it 'returns a message saying refresh token expired' do 
                expect(json['message']).to eq('Refresh token expired')
                expect(response).to have_http_status(:unprocessable_entity)
            end
        end
        context 'with invalid refresh token' do 
            invalid_refresh_token = "i.v.rt"
            before do
                allow(JsonWebToken).to receive(:decode).with(invalid_refresh_token).and_return(nil)
                post '/refresh', params: {refresh_token: invalid_refresh_token}
            end

            it 'returns a message saying refresh token expired' do 
                expect(json['message']).to eq('Invalid refresh token')
                expect(response).to have_http_status(:unprocessable_entity)
            end
        end
    end

    describe 'login the user' do 
        # post '/login', to:'users#login'
        context 'with valid parameters but the user is not verified' do 
            let!(:user) { FactoryBot.create(:user)}

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

end