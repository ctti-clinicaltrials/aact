Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  namespace :api, defaults: { format: :json } do
    namespace :studies do
      resources :counts_by_year, only: :index
    end

    resources :studies, param: :nct_id, only: [:show, :index]
  end
end
