Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }
  resources :dashboards do
    collection do
      get :settings
    end

    member do
      get :get_download_url
    end
  end

  resources :boards do
    collection do
      get :export
      get :export_archived
    end
  end

  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  resources :users do
    member do
      patch :update
    end
  end

  root 'static_pages#index'
end
