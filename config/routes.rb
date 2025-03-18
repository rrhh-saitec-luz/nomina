# Frozen_string_literal: true

Rails.application.routes.draw do
  resources :tab_trabajadors do
    get %i[index new show edit update destroy]
  end

  resources :pagos do
    collection do
      get 'index', action: :index
      get 'show', action: :show
    end
  end

  resources :variacions do
    collection do
      get 'index', action: :index
      get 'show', action: :show
    end
  end
  devise_for :users
  get 'home/index'
  root to: 'home#index'
end
