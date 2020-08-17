# frozen_string_literal: true

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
      raise "index #{key.inspect} not set!" if !indices.key?(key)

      uuid = indices[key][val]

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

    # The below is kind of a messy mechanism for using this parentclass
    # as a memory store for all the state of its derived classes. All
    # child classes will also have a `global_uuid_store` technically
    # but only this parent class' will get used.

    def uuid_store
      # NB: models gets auto-reloaded but this superclass does not since
      # it's in `lib`. When models get reloaded their object_id changes
      # which means we have to store them by the "name" of the class so
      # that their data doesn't get cleared on reload.
      MemoryModel.send(:global_uuid_store)[self.to_s.to_sym] ||= {}
    end

    # All models share the same uuid store
    def global_uuid_store
      @global_uuid_store ||= {}
    end
  end

  property :uuid, required: true
  private :uuid=

  def initialize(**args)
    super(**args, uuid: SecureRandom.uuid)
  end

  def to_s(*)
    super.gsub /^{/, "{#{self.class} "
  end
end
