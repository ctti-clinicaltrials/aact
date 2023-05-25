require 'roo'
require 'csv'

namespace :db do
  task :schema_png, [:file_name] => :environment do |t, args|
    Util::DbImageGenerator.new.schema_image(args[:file_name])
  end
end
