Rails.application.routes.draw do
  get 'tab_trabajadors/index'
  get 'tab_trabajadors/new'
  get 'tab_trabajadors/show'
  post 'tab_trabajadors/create'
  get 'tab_trabajadors/edit'
  get 'tab_trabajadors/update'
  get 'tab_trabajadors/destroy'
  get 'pagos/index'
  get 'pagos/show'
  get 'pagos/variaciones'
  devise_for :users
  get 'home/index'
  root to: 'home#index'
end
