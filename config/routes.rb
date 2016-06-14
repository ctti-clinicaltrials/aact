Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  namespace :api, defaults: { format: :json } do
    resources :studies, param: :nct_id, only: [:show, :index]
  end
end
