Rails.application.routes.draw do

  require 'sidekiq/web'
  mount AACT2::Base, at: '/'
  mount Sidekiq::Web => '/sidekiq'

  root "pages#home"

  get '/.well-known/acme-challenge/:id' => 'pages#letsencrypt'
  get "wdc"                   => "tableau#index"
  get '/old_tableau',         :to => redirect('/tableau.html')
  get "api_docs"              => "swaggerui#index"
  get "/learn_more"           => "pages#learn_more"
  get "/schema"               => "pages#schema"
  get "/data_dictionary"      => "dictionary#show"
  get "/activities"           => "database_activity#show"
  get 'dictionary/show'

  get "/connect"              => "pages#connect"
  get "/pgadmin"              => "pages#pgadmin"
  get "/r"                    => "pages#r"
  get "/sas"                  => "pages#sas"
  get "/psql"                 => "pages#psql"
  get "/api_connect"          => "pages#api_connect"
  get "/frequently_asked_questions" => "pages#frequently_asked_questions"
  get "/background"           => "pages#background"

  get "/points_to_consider"   => "pages#points_to_consider"
  get "/news"                 => "pages#news"

  get "/download"             => "pages#download"
  get "/snapshots"            => "pages#snapshots"
  get "/pipe_files"           => "pages#pipe_files"
  get "/pipe_files_with_r"    => "pages#pipe_files_with_r"
  get "/pipe_files_with_sas"  => "pages#pipe_files_with_sas"
  get "/snapshot_archive"     => "pages#snapshot_archive"

  get "/sanity_check_report"  => "pages#sanity_check", as: :sanity_check

  resources :definitions
  resources :use_cases
  resources :database_activity
end
