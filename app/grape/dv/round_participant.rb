module DV
  class RoundParticipant < Grape::API
    format :json

    namespace :round_participants do
      route_param :uuid do
        desc 'Get one round participant.'
        params do
          requires :uuid, type: String, desc: 'Round participant uuid'
        end

        get do
          if RoundParticipant.has_uuid?(params[:uuid])
            present RoundParticipant.by_uuid(params[:uuid]), with: DV::Representers::Participant
          else
            error! 'Round participant not found!', 404
          end
        end
      end
    end
  end
end
