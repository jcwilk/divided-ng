require 'roar/json/hal'

module DV
  module Representers
    module Base
      module ClassMethods
        def render(obj)
          # to_json is in representable-3.0.4/lib/representable/json.rb:44
          # which calls to_hash in roar-1.1.0/lib/roar/json/hal.rb:58
          # which calls super (to_hash) representable-3.0.4/lib/representable/hash.rb:34
          # calls create_representation_with representable-3.0.4/lib/representable.rb:45
          # this used to be `env:` but I changed it to `user_options:` to conform with representable
          new(obj).to_json(user_options: {
            "rack.url_scheme" => 'http',
            "HTTP_HOST" => Divided::CANONICAL_HOST
          })
        end

        def render_hash(*args)
          JSON.parse(render(*args))
        end
      end

      def self.included(klass)
        klass.instance_eval do
          include Roar::JSON::HAL

          curies do |opts|
            [
              name: :dv,
              href: "http://github.com/divided"
            ]
          end
        end
        klass.extend(ClassMethods)
      end

      private

      def method_missing(*args)
        if represented.respond_to?(args.first)
          represented.send(*args)
        else
          super
        end
      end

      def respond_to?(*args)
        super || represented.respond_to?(*args)
      end

      def build_url(opts, path)
        URI.parse(base_url(opts)).tap do |uri|
          uri.path = ''
        end.to_s+path
      end

      def base_url(opts)
        if opts[:env].present?
          request = Grape::Request.new(opts[:env])
          request.base_url
        else
          puts "Warning! Unable to get hostname"
          "http://missing.example.com"
        end
      end
    end
  end
end
