Rails.application.routes.draw do
  resources :reports do
    collection do
      get 'by_country/:country' => 'reports#by_country', as: "by_country"
      get 'by_region/:region_id' => 'reports#by_region', as: "by_region"
      post SECRET => 'reports#secret_create'
    end
  end
  resources :regions do
    collection do
      post SECRET => 'regions#secret_create'
    end
  end
  resources :body_texts do
    collection do
      get 'search'
      post SECRET => "body_texts#secret_create"
    end
  end
  resources :authorships
  resources :authors do
    collection do
      post SECRET => "authors#secret_create"
    end
  end
  resources :papers do
    collection do
      get 'search'
      post SECRET => "papers#secret_create"
    end
  end
  root 'papers#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
