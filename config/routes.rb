Parsads::Application.routes.draw do
  resources :pages
  root to: 'pages#new' 
end
