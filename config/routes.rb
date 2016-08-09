Rails.application.routes.draw do
  get 'dictionary/show'

  require 'sidekiq/web'
  mount AACT2::Base, at: '/'
  mount Sidekiq::Web => '/sidekiq'
  get "api_docs" => "swaggerui#index"

  get "/data_dictionary" => "dictionary#show"

  root "pages#home"

  get "/learn_more" => "pages#learn_more"
  get "/points_to_consider" => "pages#points_to_consider"
  get "/download_aact" => "pages#download_aact"
  get "/snapshot_archive" => "pages#snapshot_archive"
  get "/sanity_check_report" => "pages#sanity_check", as: :sanity_check

  resources :definitions
end
