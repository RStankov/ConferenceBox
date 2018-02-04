# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :conferences
    resources :events do
      resource :notes, controller: 'event_notes', only: %i[edit update]
      resources :photos, controller: 'photos', only: %i[index create destroy] do
        patch :reorder, on: :collection
      end
      resources :feedbacks, only: %i[index destroy], shallow: true
    end
    resources :sessions, only: %i[new create edit update destroy]
    resources :speakers
    resources :subscribers, only: %i[index create update destroy]

    resource :user, only: %i[edit update]

    root to: redirect('/admin/conferences')
  end

  namespace :sign do
    get    :in,  to: 'sessions#new'
    post   :in,  to: 'sessions#create'
    delete :out, to: 'sessions#destroy'
  end

  if Rails.env.test?
    get '/backdoor/login',  to: 'backdoor#login'
    get '/backdoor/logout', to: 'backdoor#logout'
  end

  resource :subscribers, only: %i[new create]
  resource :feedbacks, only: %i[new create]

  resources :speakers, only: [:show]
  resources :schedules, only: %i[index show]

  get 'unsubscribe/:token', to: 'subscribers#destroy', as: :unsubscribe

  get 'archive/:year', to: 'events#show', as: :archive
  get 'archive/:year/photos', to: 'photos#index', as: :photos

  root to: 'conferences#show'
end
