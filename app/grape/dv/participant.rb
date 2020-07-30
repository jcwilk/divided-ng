module DV
  class Participant < Grape::API
    format :json

    namespace :rooms do
      route_param :room_id do
        namespace :rounds do
          route_param :round_id do
            namespace :participants do
              route_param :participant_id do
                desc 'Get one participant.'
                params do
                  # TODO: this isn't even a param... how is this working?
                  requires :id, type: String, desc: 'Player uuid.'
                end

                get do
                  # Possible alternative - implement pooling for models and
                  # pull them up directly by uuid like with Room. kind of
                  # tempting tbh...

                  room = Room.by_uuid(params[:room_id])
                  round = room&.round_by_uuid(params[:round_id])
                  participant = round&.participant_by_uuid(params[:participant_id])

                  if participant.nil?
                    error! 'Participant not found!', 404
                  else
                    present participant, with: DV::Representers::Participant
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
