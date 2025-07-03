module NeatIds
  class NeatId
    attr_reader :sqids, :prefix

    TOKEN = 123

    def initialize(model, prefix, min_length: NeatIds.minimum_length, alphabet: NeatIds.alphabet, delimiter: NeatIds.delimiter, **options)
      @prefix = prefix.to_s
      @delimiter = delimiter.to_s
      @sqids = Sqids.new( min_length: min_length, alphabet: alphabet)
    end

    def encode(id)
      return if id.nil?
      if uuid?(id)
        nums = uuid_to_ints(id)
        return @prefix + @delimiter + @sqids.encode([TOKEN] + nums)
      end
      @prefix + @delimiter + @sqids.encode([TOKEN] + Array.wrap(id))
    end

    def decode(id, fallback: false)
      fallback_value = fallback ? id : nil
      _, id_without_prefix = NeatIds.split_id(id, @delimiter)
      decoded_hashid = @sqids.decode(id_without_prefix)

      if !valid?(decoded_hashid)
        fallback_value
      else
        _, *ids = decoded_hashid
        if ids.size == 4 && ids.all? { |n| n.is_a?(Integer) && n >= 0 && n <= 0xFFFFFFFF }
          ints_to_uuid(ids)
        else
          (ids.size == 1) ? ids.first : ids
        end
      end
    end

    private

    def valid?(decoded_hashid)
      decoded_hashid.size >= 2 && decoded_hashid.first == TOKEN
    end

    def uuid?(id)
      id.is_a?(String) && id.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end

    def uuid_to_ints(uuid)
      hex = uuid.delete('-')
      [0, 8, 16, 24].map { |i| hex[i, 8].to_i(16) }
    end

    def ints_to_uuid(ints)
      hex = ints.map { |n| n.to_s(16).rjust(8, '0') }.join
      "#{hex[0,8]}-#{hex[8,4]}-#{hex[12,4]}-#{hex[16,4]}-#{hex[20,12]}"
    end
  end
end
