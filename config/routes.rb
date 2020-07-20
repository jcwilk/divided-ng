Rails.application.routes.draw do
  root 'game_client#show'

  mount ActionCable.server => '/cable'
end
