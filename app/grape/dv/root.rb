module DV
  class Root < Grape::API
    format :json
    formatter :json, Grape::Formatter::Roar

    desc 'The API root.'
    params do
    end
    get do
      present self, with: DV::Representers::Root
    end

    mount DV::CurrentRound
    mount DV::Join
    mount DV::Move
    mount DV::Room
    mount DV::RoomParticipant
    mount DV::Rooms
    mount DV::Round
    mount DV::RoundParticipant

    # add_swagger_documentation api_version: 'v1'
  end
end
