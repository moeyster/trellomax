Rails.application.routes.draw do
  resources :dashboards

  root 'static_pages#index'
end
