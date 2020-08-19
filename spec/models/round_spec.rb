require 'rails_helper'

describe Round do
  let(:room) { Junk.room }
  let(:user) { Junk.user }
  let(:participant) { Junk.room_participant(user: user) }

  def start
    Round.start
  end

  describe "Round.start" do
    subject { start }

    it "has no participants" do
      expect(subject.participants).to be_empty
    end
  end
end
