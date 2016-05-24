class DailyImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'daily_import'

  def perform
    User.create(email: "me@example.com")
  end
end
