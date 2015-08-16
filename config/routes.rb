Rails.application.routes.draw do
  resources :products, param: :barcode, defaults: { format: :json }
end
