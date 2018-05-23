# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = (ENV["ASSETS_VERSION"] || "1.0")
Rails.application.config.assets.precompile += %w( styles.css )
Rails.application.config.assets.precompile += %w( use_cases/use_cases.css )
Rails.application.config.assets.precompile += %w( users/users.css )
Rails.application.config.assets.precompile += %w( index.css )

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
