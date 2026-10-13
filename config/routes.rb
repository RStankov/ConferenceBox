# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :conferences do
      resources :events, only: %i(index)
    end
    resources :events do
      resource :notes, controller: 'event_notes', only: %i(edit update)
      resources :photos, controller: 'photos', only: %i(index create destroy) do
        patch :reorder, on: :collection
      end
      resources :feedbacks, only: %i(index destroy), shallow: true
      namespace :cfp do
        resource :window, only: %i(new create edit update destroy)
        resources :proposals, only: %i(index show)
        resource :decisions, only: %i(create)
        resource :decision_emails, only: %i(new create)
        resource :reviewer_reminders, only: %i(create)
        post 'assignments/auto', to: 'assignments#auto', as: :auto_assignments
      end
    end
    resources :sessions, only: %i(new create edit update destroy)
    resources :speakers
    resources :sponsors

    namespace :cfp do
      resources :reviews, only: %i(index)
      resources :proposals, only: [] do
        resource :review, only: %i(show create update) do
          post :conflict
        end
        resources :comments, only: %i(create)
        resources :assignments, only: %i(create destroy)
        resource :promotion, only: %i(create)
      end
    end

    resource :user, only: %i(edit update)
    resources :team_members, only: %i(index edit update)

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

  resource :feedbacks, only: %i(new create)
  resource :cfp, only: %i(show), controller: 'cfp'

  namespace :cfp do
    resources :submissions, param: :token, only: %i(new create show edit update) do
      member do
        post :submit
        post :withdraw
      end
    end
  end

  resources :speakers, only: [:show]
  resources :schedules, only: %i(index show)

  get 'archive/:year', to: 'events#show', as: :archive
  get 'archive/:year/photos', to: 'photos#index', as: :photos

  root to: 'conferences#show'
end
