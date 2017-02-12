# save admin database settings in global var
DB_ADMIN = YAML::load(ERB.new(File.read(Rails.root.join("config","database_admin.yml"))).result)[Rails.env]

