module DV
  class Join < Grape::API
    format :json

    namespace :rooms do
      route_param :room_uuid do
        namespace :join do
          desc 'Join the room.'
          params do
            requires :room_uuid, type: String, desc: 'Room uuid'
          end

          post do
            user_uuid = env["action_dispatch.cookies"].signed["user_uuid"]
            if !::User.has_uuid?(user_uuid)
              error! "Unknown user!", 401
            end

            if !::Room.has_uuid?(params[:room_uuid])
              error! "Missing room!", 404
            end

            user = ::User.by_uuid(user_uuid)
            participant = ::Room.by_uuid(params[:room_uuid]).join(user)

            present participant, with: DV::Representers::RoomParticipant
          end
        end
      end
    end
  end
end
