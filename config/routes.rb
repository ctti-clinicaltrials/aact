Rails.application.routes.draw do
  require 'sidekiq/web'
  mount AACT2::Base, at: '/'
  mount Sidekiq::Web => '/sidekiq'
  get "apiexplorer" => "swaggerui#index"
  root "pages#home"

  get "/snapshot_archive" => "pages#snapshot_archive"
end
