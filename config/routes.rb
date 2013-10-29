CreditCard::Application.routes.draw do
  # resources :transaction
  get "/transaction/new", "transaction#new"
  get "/transaction/index", "transaction#index"
  get "/transaction/process_transaction"
  root :to => "transaction#new"

end
