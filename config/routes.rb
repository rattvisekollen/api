Rails.application.routes.draw do
  resources :products, param: :barcode, defaults: { format: :json } do
    collection do
      get "count"
    end
  end
end
