# frozen_string_literal: true

require 'rails_helper'

describe 'login behavior' do
  def signed_cookies
    ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash).signed
  end

  before do
    get "/404.html" # to set up cookies
  end

  context "with a blank prior value" do
    it "assigns a user" do
      expect { get "/" }.to change { signed_cookies[:user_uuid] }.from(nil)
    end
  end
end
