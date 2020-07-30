class MemoryModel < Hashie::Dash
  class HasMany
    attr_reader :klass, :uuids, :indices

    def initialize(klass, indices: [], members: [])
      @indices = indices.reduce({}) { |acc, el| acc.merge(el => {}) }
      @klass = klass

      @uuids = Set.new

      members.each { |member| self << member }
    end

    def all
      klass.by_uuids(*uuids)
    end

    def has?(key, val)
      uuid = indices[key]&.public_send(:[],val)

      uuid ? klass.has_uuid?(uuid) : false
    end

    def has_uuid?(uuid)
      klass.has_uuid?(uuid)
    end

    def <<(member)
      indices.each do |key, index|
        val = member.public_send(key)
        index[val] = member.uuid
      end

      uuids << member.uuid
    end

    def by(key, val)
      uuid = indices.fetch(key).fetch(val)

      klass.by_uuid(uuid)
    end

    def by_uuid(uuid)
      raise "missing key" if !has_uuid?(uuid)

      klass.by_uuid(uuid)
    end
  end

  class HasOne
    def initialize(klass, member)
      # TODO
    end
  end

  class << self
    # TODO: Add a has_many manager

    def all
      uuid_store.values
    end

    def by_uuid(uuid)
      uuid_store.fetch(uuid)
    end

    def by_uuids(*uuids)
      uuid_store.fetch_values(*uuids)
    end

    def has_uuid?(uuid)
      uuid_store.key?(uuid)
    end

    def new(*)
      super.tap do |obj|
        uuid_store[obj.uuid] = obj
      end
    end

    private

    # All models share the same uuid store
    def uuid_store
      if self.class == MemoryModel
        @uuid_store ||= {}
      else
        MemoryModel.send(:uuid_store)
      end
    end
  end

  property :uuid, required: true
  private :uuid=

  def initialize(**args)
    super(**args, uuid: SecureRandom.uuid)
  end
end
