# frozen_string_literal: true

class DVChannel < ApplicationCable::Channel
  def self.current_round_key(room_uuid:)
    "dv_room_#{room_uuid}_current_round"
  end

  def subscribed
    # TODO: This will become more generalized as needed
    # See commented out code below for ideas on roughly how
    if matches = params[:key].match(/\Adv_room_([^_]+)_current_round\z/)
      uuid = matches.captures.first
      room = Room.by_uuid(uuid)

      DeferredCall.enqueue(room, :join, current_user)

      stream_from params[:key]
      transmit Room.by_uuid(uuid).current_round.dv_hash
    else
      reject
    end
  end

  def unsubscribed
    DeferredCall.enqueue(room, :disconnected, current_user)
  end

  private

  def valid_key?
    params[:key].match(/\Adv_room_([^_]+)_current_round\z/)
  end

  def room
    matches = params[:key].match(/\Adv_room_([^_]+)_current_round\z/)
    uuid = matches.captures.first
    room = Room.by_uuid(uuid)
  end

  # def subscribed
  #   subpath = params[:href].gsub(/\A\/dv/,'')
  #   route = DV::Root.routes.find { |route| route.match? subpath }

  #   if route
  #     # TODO: needs to retain the headers (cookies, specifically)
  #     mock = Rack::MockRequest.env_for(subpath)

  #     # how the heck am i going to test this
  #     ret = route.exec(mock)
  #     if ret.first >= 200 && ret.first < 300
  #       stream_from "dvlisten:#{subpath}"
  #     else
  #       reject_unauthorized_connection
  #     end
  #   else
  #     reject_unauthorized_connection
  #   end

  #   # if params[:key] =~ /\Adv_/
  #   #   stream_from params[:key]
  #   # else
  #   #   raise "bogus or missing rel_path"
  #   # end
  # end

  # def unsubscribed
  #   # Any cleanup needed when channel is unsubscribed
  # end
end
