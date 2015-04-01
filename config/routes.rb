Rails.application.routes.draw do
  root to: 'visitors#index'
  resources :subscribers
  resources :stories do
    collection do
      get :tomorrow
      get :yesterday
    end
  end
end
