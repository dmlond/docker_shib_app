Rails.application.routes.draw do
  get '/auth/shibboleth', as: 'shibboleth_login'
  get '/auth/:provider/callback', to: 'auth#login'
  get 'auth/splash', as: 'splash'
  get 'auth/login'
  get 'auth/destroy', as: 'logout'
  root 'auth#splash'
end
