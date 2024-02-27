class ForgotPasswordMailer < ApplicationMailer
    default from: "personaluse24032002@gmail.com"
    def otp_email 
        @user = params[:user]
        @otp = params[:otp]
        # byebug
        mail(to: @user.email, subject: 'Password reset OTP')
    end
end
