require "neat_ids/version"
require "neat_ids/engine"

require "sqids"

module NeatIds
  class Error < StandardError; end

  autoload :NeatId, "neat_ids/neat_id"

  mattr_accessor :delimiter, default: "_"
  mattr_accessor :alphabet, default: "abcdefghijklmnopqrstuvwxyz1234567890"
  mattr_accessor :minimum_length, default: 24

  mattr_accessor :models, default: {}

  def self.find(neat_id)
    prefix, _ = split_id(neat_id)
    models.fetch(prefix).find_by_neat_id(neat_id)
  rescue KeyError
    raise Error, "Unable to find model with prefix `#{prefix}`. Available prefixes are: #{models.keys.join(", ")}"
  end

  # Splits a prefixed ID into its prefix and ID
  def self.split_id(neat_id, delimiter = NeatIds.delimiter)
    prefix, _, id = neat_id.to_s.rpartition(delimiter)
    [prefix, id]
  end

  def self.register_prefix(prefix, model:)
    if (existing_model = NeatIds.models[prefix]) && existing_model != model
      raise Error, "Prefix #{prefix} already defined for model #{model}"
    end

    NeatIds.models[prefix] = model
  end

  # Adds `has_neat_id` method
  module Rails
    extend ActiveSupport::Concern

    included do
      class_attribute :_neat_id
      class_attribute :_neat_id_fallback
    end

    class_methods do
      def has_neat_id(prefix, override_find: true, override_param: true, fallback: true, **options)
        include Attribute
        include Finder if override_find
        include ToParam if override_param
        self._neat_id = NeatId.new(self, prefix, **options)
        self._neat_id_fallback = fallback

        # Register with NeatIds to support NeatIds#find
        NeatIds.register_prefix(prefix.to_s, model: self)
      end
    end
  end

  # Included when a module uses `has_neat_id`
  module Attribute
    extend ActiveSupport::Concern

    class_methods do
      def find_by_neat_id(id)
        find_by(id: _neat_id.decode(id))
      end

      def find_by_neat_id!(id)
        find_by!(id: _neat_id.decode(id))
      end

      def neat_id(id)
        _neat_id.encode(id)
      end

      def neat_ids(ids)
        ids.map { |id| neat_id(id) }
      end

      def decode_neat_id(id)
        _neat_id.decode(id)
      end

      def decode_neat_ids(ids)
        ids.map { |id| decode_neat_id(id) }
      end
    end

    def neat_id
      _neat_id.encode(id)
    end
  end

  module Finder
    extend ActiveSupport::Concern

    class_methods do
      def find(*ids)
        # Skip if model doesn't use prefixed ids
        return super if _neat_id.blank?

        neat_ids = ids.flatten.map do |id|
          neat_id = _neat_id.decode(id, fallback: _neat_id_fallback)
          raise Error, "#{id} is not a valid neat_id" if !_neat_id_fallback && neat_id.nil?
          neat_id
        end
        neat_ids = [neat_ids] if ids.first.is_a?(Array)

        super(*neat_ids)
      end

      def relation
        super.tap { |r| r.extend ClassMethods }
      end

      def has_many(*args, &block)
        options = args.extract_options!
        options[:extend] = Array(options[:extend]).push(ClassMethods)
        super(*args, **options, &block)
      end
    end
  end

  module ToParam
    extend ActiveSupport::Concern

    def to_param
      _neat_id.encode(id)
    end
  end
end
