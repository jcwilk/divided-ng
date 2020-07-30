class MemoryModel < Hashie::Dash
  class << self
    # TODO: Add a has_many manager

    def all
      store.values
    end

    def by_uuid(uuid)
      store[uuid]
    end

    def reset
      @store = {}
    end

    def new(*)
      super.tap do |obj|
        store[obj.uuid] = obj
      end
    end

    private

    def store
      @store ||= {}
    end
  end

  property :uuid, required: true
  private :uuid=

  def initialize(**args)
    super(**args, uuid: SecureRandom.uuid)
  end
end
