# This is only one example of configuring ActionMailer, in this case SendGrid.
# For more information, read: https://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration

Rails.application.configure do
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: "smtp.sendgrid.net",
    port: 587,
    domain: ENV["SENDGRID_DOMAIN"],
    user_name: ENV["SENDGRID_USERNAME"],
    password: ENV["SENDGRID_KEY"],
    authentication: "plain",
    enable_starttls_auto: true
  }
end
