Rails.application.routes.draw do
  devise_for :users, path: '',
                     controllers: {
                       registrations: 'users/registrations',
                       sessions: 'users/sessions',
                       omniauth_callbacks: 'users/omniauth_callbacks'
                     },
                     path_names: {
                       sign_in: 'login',
                       sign_out: 'logout',
                       sign_up: 'register'
                     }

  resources :jobs
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  root to: 'jobs#new'

  resources :cover_letters, only: [:show]

  # authenticate :user, ->(u) { u.admin? } do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  # end
end
