Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :chess_boards, only: :create do
    collection do
      get 'get_shortest_path'
    end
  end
end
