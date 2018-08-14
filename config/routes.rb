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
  resources :users
  root 'static_pages#index'

  authenticate :user, lambda {|u| u.role >= 10 } do
    mount Resque::Server.new, :at => "/resque"
  end
end
