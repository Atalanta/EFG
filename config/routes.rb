EFG::Application.routes.draw do
  devise_for :users

  root to: 'dashboard#show'

  resources :loans, only: [:index, :show] do
    collection do
      resource :eligibility_check, only: [:new, :create]
    end

    resource :entry, only: [:new, :create], controller: 'loan_entries'
    resource :offer, only: [:new, :create], controller: 'loan_offers'
    resource :guarantee, only: [:new, :create], controller: 'loan_guarantees'
  end

  get 'loans/state/:id' => 'loan_states#show', as: 'loan_state'

  resources :users, only: [:index, :show, :new, :create, :edit, :update]
end
