module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      if User.has_uuid?(cookies.signed[:user_uuid])
        User.by_uuid(cookies.signed[:user_uuid])
      else
        reject_unauthorized_connection
      end
    end
  end
end
