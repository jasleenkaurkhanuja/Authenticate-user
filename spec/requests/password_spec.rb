require 'rails_helper'

def json 
    JSON.parse(response.body)
end

RSpec.describe "Password", type: :request do 
    describe 'forgot_password' do 
        # post '/forgot_password', to: 'passwords#forgot'
        let(:my_user) {FactoryBot.create(:user, verification: "true", email: "jasleenkaurkhanuja03@gmail.com")}
        let(:access_token) {JsonWebToken.encode(user_id: my_user.id)}

        context 'when the email is not present' do
            it 'returns an error message' do 
                post '/forgot_password', params: { email: ''}
                expect(json['error']).to eq('Email not present')
                expect(response).to have_http_status(:unprocessable_entity)
            end
        end

        context 'when the user id not present' do 
            it 'return No user found, error message' do 
                post '/forgot_password', params: {email: 'nonexistingemail@example.com'}
                expect(response).to have_http_status(:unprocessable_entity)
                expect(json['error']).to eq("No user found")
            end
        end

        context 'when user is present with valid params' do 
            it 'returns a message saying, Email sent successfully' do 
                post '/forgot_password', params: {email: my_user.email}
                expect(response).to have_http_status(:ok)
                expect(json['otp']).to be_present
                expect(json['message']).to eq("Email sent successfully")
            end
        end
    end

    describe 'reset_password' do 
        let(:my_user) {FactoryBot.create(:user, verification: "true")}

        context 'user exists and has entered the correct otp' do 
            it 'returns password updated successfully' do 
                # post '/reset', to: 'passwords#reset'
                post '/reset', params: 
                {
                    user:
                    {
                        email: my_user.email,
                        password: "Jk12345#", 
                        otp: my_user.otp
                    } 
                }
                expect(json['message']).to eq("password updated successfully")
                expect(response).to have_http_status(:ok)
            end
        end

        context 'wrong otp entered or user does not exists' do 
            it 'returns wrong otp' do 
                post '/reset', params:
                {
                    user: 
                    {
                        email: my_user.email,
                        password: "Jk12345#", 
                        otp: 89
                    }
                }
                expect(json['message']).to eq( "wrong otp or the user does not exists")
                expect(response).to have_http_status(:unprocessable_entity)
            end

            it 'returns does not exists' do 
                post '/reset', params:
                {
                    user: 
                    {
                        email: 'jk@example.com',
                        password: "Jk12345#", 
                        otp: my_user.otp
                    }
                }
                expect(json['message']).to eq( "wrong otp or the user does not exists")
                expect(response).to have_http_status(:unprocessable_entity)
            end
        end
    end
end