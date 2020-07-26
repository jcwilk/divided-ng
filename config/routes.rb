Rails.application.routes.draw do
  root 'game_client#show'

  mount ActionCable.server => '/cable'

  mount DV::Root => '/dv'
end
