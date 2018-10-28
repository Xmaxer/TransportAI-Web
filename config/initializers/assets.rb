# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.precompile += %w( custom/register.js )
Rails.application.config.assets.precompile += %w( dashboard/dashboard.css )
Rails.application.config.assets.precompile += %w( dashboard/plugins/perfect-scrollbar.jquery.min.js )
Rails.application.config.assets.precompile += %w( dashboard/plugins/bootstrap-notify.js )
Rails.application.config.assets.precompile += %w( dashboard/black-dashboard.css )
Rails.application.config.assets.precompile += %w( dashboard/nucleo-icons.css )
Rails.application.config.assets.precompile += %w( dashboard/black-dashboard.js )
Rails.application.config.assets.precompile += %w( dashboard/ciaracss.css )
# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
