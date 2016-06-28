Rails.application.routes.draw do
  apipie
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  root "pages#home"

  namespace :api, defaults: { format: :json } do
    namespace :studies do
      resources :counts_by_year, only: :index
    end

    resources :studies, param: :nct_id, only: [:show, :index]
  end

end
