SMTP_SETTINGS = {
  address: ENV["SMTP_ADDRESS"] || ENV["MAILGUN_SMTP_SERVER"], # example: "smtp.sendgrid.net"
  authentication: :plain,
  domain: ENV["SMTP_DOMAIN"] || ENV["MAILGUN_DOMAIN"], # example: "heroku.com"
  enable_starttls_auto: true,
  password: ENV["SMTP_PASSWORD"] || ENV["MAILGUN_SMTP_PASSWORD"],
  port: "587",
  user_name: ENV["SMTP_USERNAME"] || ENV["MAILGUN_SMTP_LOGIN"]
}
