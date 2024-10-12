class UserMailer < ApplicationMailer
    default from: 'support@thepicmeapp.com'
    def otp_email(user)
      @user = user
      @otp_code = user.otp
      mail(to: @user.email, subject: 'Your OTP for Email Verification')
    end
  
    def reset_password(user, url)
      @user = user
      @url = url
      mail(to: user.email, :subject => "Forgot Password")
    end
end