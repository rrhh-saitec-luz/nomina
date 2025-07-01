# Frozen_string_literal: true

Rails.application.routes.draw do
  get 'admins/index'
  resources :tab_trabajadors do
    get %i[index new show edit update destroy]
  end

  resources :pagos do
    collection do
      get %i[index show]
    end
  end

  resources :variacions do
    collection do
      get :nomina_espc_tipos
    end
  end

  resources :admins do
    collection do
      get 'index', action: :index
      get 'generar_nomina', action: :generar_nomina
      post 'prenomina', action: :prenomina
      get 'modificar_prenomina', action: :modificar_prenomina
      post 'actualizar', action: :actualizar_prenomina
    end
  end

  devise_for :users
  get 'home/index'
  root to: 'home#index'
end
