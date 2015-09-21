Rails.application.routes.draw do
  resources :products, param: :barcode, defaults: { format: :json } do
    collection do
      get "count"
      get "random"
    end
  end
end
