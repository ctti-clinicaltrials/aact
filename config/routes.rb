Rails.application.routes.draw do
  require 'sidekiq/web'

  devise_for :users, controllers: { registrations: 'users/registrations',
                                    confirmations: 'users/confirmations',
                                    passwords:     'users/passwords'}

  mount Sidekiq::Web => '/sidekiq'

  root "pages#home"

  get "/learn_more"           => "pages#learn_more"
  get "/schema"               => "pages#schema"
  get "/data_dictionary"      => "dictionary#show"
  get "/credentials"          => "credentials#show"
  get "/activities"           => "database_activity#show"
  get 'dictionary/show'

  get "/connect"              => "pages#connect"
  get "/pgadmin"              => "pages#pgadmin"
  get "/r"                    => "pages#r"
  get "/sas"                  => "pages#sas"
  get "/psql"                 => "pages#psql"
  get "/frequently_asked_questions" => "pages#frequently_asked_questions"
  get "/background"           => "pages#background"
  get "/release_notes"        => "pages#release_notes"
  get "/update_policy"        => "pages#update_policy"

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
  resources :users
  resources :use_cases
  resources :use_case_attachments
end
