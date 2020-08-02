# frozen_string_literal: true

require "rails_helper"

# Controller specs are frowned upon but cookie setting and getting from tests
# is super broken in request specs. I started to futz with trying to do it
# manually but apparently setting signed cookies Just Works in controller
# specs so good enough for me!

describe GameClientController do
  describe "GET show" do
    context "with a blank prior value" do
      it "assigns a user" do
        expect { get :show }.to change { cookies.signed[:user_uuid] }.from(nil)
      end
    end

    context "with a bogus prior value" do
      before do
        cookies.signed[:user_uuid] = "bogus"
      end

      it "overwrites with a new value" do
        expect { get :show }.to change { cookies.signed[:user_uuid] }.from("bogus")
      end
    end

    context "with a prior uuid of an existing user" do
      let(:user_uuid) { User.new.uuid }

      before do
        cookies.signed[:user_uuid] = user_uuid
      end

      it "does not change the cookie" do
        expect { get :show }.not_to change { cookies.signed[:user_uuid] }.from(user_uuid)
      end
    end
  end
end
