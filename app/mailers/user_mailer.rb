class UserMailer < ApplicationMailer
    def account_verification
        @user = params[:user]
        @verification_url = params[:verification_url]
        mail(to: @user.email, subject: 'Verify your account')
    end
end
