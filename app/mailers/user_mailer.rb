class UserMailer < ApplicationMailer
    def password_reset_email(user)
        @user = user
        mail(to: @user.email, subject: 'password reset for typo-graphy')
    end
end
