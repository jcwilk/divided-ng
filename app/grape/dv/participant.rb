module DV
  class Participant < Grape::API
    format :json

    namespace :participant do
      route_param :id do
        desc 'Get one room.'
        params do
          requires :id, type: String, desc: 'Player uuid.'
        end

        get do
          # TODO: Update this to the new system
          # we might need MemoryModel pooling now to find by id
          # or it could represent the full path in the url
          # /rooms/:room_id/rounds/:round_id/participants/:participant_id
          player = ::Player.alive_by_uuid(params[:id])
          if player.nil?
            error! 'Participant not found!', 404
          else
            present player, with: DV::Representers::Participant
          end
        end
      end
    end
  end
end
