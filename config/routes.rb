Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }
  resources :dashboards do
    collection do
      get :settings
    end
  end

  resources :boards do
    collection do
      get :export
    end
  end
  resources :users
  root 'static_pages#index'
end
