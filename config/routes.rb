Rails.application.routes.draw do
  require 'sidekiq/web'
  mount AACT2::Base, at: '/'
  mount Sidekiq::Web => '/sidekiq'
  get "apiexplorer" => "swaggerui#index"
  root "pages#home"

  # namespace :api, defaults: { format: :json } do
  #   namespace :studies do
  #     resources :counts_by_year, only: :index
  #   end
  #
  #   resources :studies, param: :nct_id, only: [:show, :index]
  # end

end
