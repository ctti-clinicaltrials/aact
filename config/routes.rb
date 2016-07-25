Rails.application.routes.draw do
  get 'dictionary/show'

  require 'sidekiq/web'
  mount AACT2::Base, at: '/'
  mount Sidekiq::Web => '/sidekiq'
  get "api_docs" => "swaggerui#index"

  get "/data_dictionary" => "dictionary#show"

  root "pages#home"

  get "/snapshot_archive" => "pages#snapshot_archive"
end
