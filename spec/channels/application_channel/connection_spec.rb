# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) { Junk.user }

  it "successfully connects with cookies" do
    # set "virtual" request cookies
    cookies.signed[:user_uuid] = user.uuid

    # `connect` method represents the websocket client
    # connection to the server
    connect "/cable"

    # and now we can check that the identifier was set correctly
    expect(connection.current_user).to eq user
  end

  it "rejects connection without cookies" do
    # test that the connection is rejected if no cookie provided
    expect { connect "/cable" }.to have_rejected_connection
  end

  it "rejects connection for unexistent user" do
    cookies.signed[:user_uuid] = -1

    expect { connect "/cable" }.to have_rejected_connection
  end
end
