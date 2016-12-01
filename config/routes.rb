Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "aggregator#index"

  get "/feed.rss", to: "aggregator#index", format: "rss", as: "rubyland_rss"

  get "/titles", to: "aggregator#index", as: :titles_only, defaults: { titles_only: true }

  get "/about", to: "aggregator#about", as: :about

  resources :sources, controller: :feed
end
