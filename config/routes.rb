Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "aggregator#index"

  get "/titles", to: "aggregator#index", as: :titles_only, defaults: { titles_only: true }

  get "/about", to: "aggregator#about", as: :about

  get "/sources", to: "feed#index", as: :sources
end
