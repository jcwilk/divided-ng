module DV
  class Moves < Grape::API
    format :json


    namespace :rooms do
      route_param :room_id do
        namespace :rounds do
          route_param :round_id do
            namespace :participants do
              route_param :participant_id do
                namespace :moves do
                  desc 'Get all the moves for a participant.'
                  params do
                    requires :id, type: String, desc: 'Participant uuid.'
                  end
                  get '/participant/:id/moves' do
                    player = ::Player.alive_by_uuid(params[:id])

                    if player
                      round = ::Room.all.first.current_round
                      participant = ::Participant.new(player: player, round: round)
                      present participant.moves, with: DV::Representers::Moves
                    else
                      error! 'Participant not found!', 404
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
