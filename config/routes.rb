Rails.application.routes.draw do
  resources :products, defaults: { format: :json }
end
