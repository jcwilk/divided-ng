module DV
  class Join < Grape::API
    format :json

    namespace :rooms do
      route_param :room_uuid do
        namespace :join do
          desc 'Join the room.'
          params do
            requires :room_uuid, type: String, desc: 'Room uuid'
            requires :user_uuid, type: String, desc: "User uuid"
          end

          post do
            if !::Room.has_uuid?(params[:room_uuid])
              error! "Missing room!", 404
            end

            if !::User.has_uuid?(params[:user_uuid])
              error! "Unknown user!", 404
            end

            user = ::User.by_uuid(params[:user_uuid])
            participant = ::Room.by_uuid(params[:room_uuid]).join(user)

            present participant, with: DV::Representers::RoomParticipant
          end
        end
      end
    end
  end
end
