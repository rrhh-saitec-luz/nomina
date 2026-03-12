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
      get 'historico', action: :historico_variaciones
    end
  end

  resources :admins do
    collection do
      get 'index', action: :index
      get 'generar_nomina', action: :generar_nomina
      get 'modificar_prenomina', action: :modificar_prenomina
      post 'prenomina', action: :prenomina
      post 'actualizar', action: :actualizar_prenomina
      get 'depurar', action: :depurar
      post 'eliminar_inactivos', action: :eliminar_inactivos
      post 'actualizar_activos', action: :actualizar_activos
      post 'destruir_prenomina'
      get 'antiguedades'
      get 'vcm', action: :verificar_cargos_multiples
      get 'detalles', action: :detalles
      patch 'editar_prenomina', action: :editar_prenomina
    end
  end

  devise_for :users
  get 'home/index'
  root to: 'home#index'
end
