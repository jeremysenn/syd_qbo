class ApplicationMailer < ActionMailer::Base
#  default from: "admin@jeremysenn.com"
  default from: "#{ENV['GMAIL_USERNAME']}@gmail.com"
  #layout 'mailer'

  def test_email
    @to = 'senn.jeremy@gmail.com'
    @subject = 'This is a test'
    @message = 'This is a test'
    mail(to: @to, subject: @subject)
  end

end
