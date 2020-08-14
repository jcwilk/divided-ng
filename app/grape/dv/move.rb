module DV
  class Move < Grape::API
    format :json

    namespace "moves" do
      route_param "uuid" do
        desc 'Choose a move.'
        params do
          # TODO: only permit the owning user to submit
          requires :uuid, type: String, desc: 'Move uuid'
        end

        post do
          user_uuid = env["action_dispatch.cookies"].signed["user_uuid"]

          if user_uuid.nil?
            error! "user_uuid not set in cookie!"
          end

          if !::Move.has_uuid?(params[:uuid])
            error! "Move not found!"
          end

          move = ::Move.by_uuid(params[:uuid])
          MoveChooser.call(move, user_uuid)

          present move, with: DV::Representers::Move
        end

        desc 'Get a move.'
        params do
          requires :uuid, type: String, desc: 'Move uuid'
        end

        get do
          if !::Move.has_uuid?(params[:uuid])
            error! "Move not found!"
          end

          move = ::Move.by_uuid(params[:uuid])
          present move, with: DV::Representers::Move
        end
      end
    end
  end
end
