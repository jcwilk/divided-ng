# frozen_string_literal: true

class DVChannel < ApplicationCable::Channel
  def subscribed
    if params[:rel_path] =~ /^\/dv\//
      stream_from params[:rel_path]
    else
      raise "bogus or missing rel_path"
    end
  end

  # def unsubscribed
  #   # Any cleanup needed when channel is unsubscribed
  # end
end
