Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resource :users, only: [] do
    get :me, :on => :member
  end

  resources :games, :only => [:create, :index, :show, :update] do
    resources :guesses, :only => [:create, :index] do
      get '', query_string: /best=/, action: :best, on: :collection
      get '', query_string: /zero=/, action: :zero, on: :collection
    end
    resources :hints, :only => [:create, :index]
  end

  resources :graphql, only: :create
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'
  end

  namespace :hooks do
    resources :telegram, :only => [] do
      post ENV['TELEGRAM_WEBHOOK'], action: :update, :on => :collection
    end
  end
end
