Rails.application.routes.draw do
  require 'sidekiq/web'
  mount AACT2::Base, at: '/'
  mount Sidekiq::Web => '/sidekiq'
  get "api_docs" => "swaggerui#index"
  root "pages#home"

  get "/learn_more" => "pages#learn_more"
  get "/points_to_consider" => "pages#points_to_consider"
  get "/snapshot_archive" => "pages#snapshot_archive"
end
