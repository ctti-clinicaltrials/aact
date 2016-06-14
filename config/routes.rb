Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  namespace :api, defaults: { format: :json } do
    get '/studies/:nct_id' => 'studies#show'
  end
end
