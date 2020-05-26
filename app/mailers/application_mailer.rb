class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.gmail[:email]
  layout 'mailer'
end
