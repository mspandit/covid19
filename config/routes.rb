Rails.application.routes.draw do
  resources :us_reports do
    collection do
      post SECRET => 'us_reports#secret_create'
      get 'state/:state' => 'us_reports#state', as: "state"
    end
  end
  resources :questions do
    member do
      post 'ask' => "questions#ask"
    end
  end
  get 'home/start'
  resources :reports do
    collection do
      get 'by_country/:country' => 'reports#by_country', as: "by_country"
      get 'by_region/:region_id' => 'reports#by_region', as: "by_region"
      get 'compare' => 'reports#compare', as: "country_comparison"
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
  root 'home#start'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
