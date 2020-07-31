module DV
  class Round < Grape::API
    format :json

    namespace :round do
      route_param :uuid do
        desc 'Get a round.'
        params do
          requires :uuid, type: String, desc: 'Round uuid'
        end

        get do
          if ::Round.has_uuid?(params[:uuid])
            present ::Round.by_uuid(params[:uuid]), with: DV::Representers::Round
          else
            error! 'Round not found!', 404
          end
        end
      end
    end
  end
end
