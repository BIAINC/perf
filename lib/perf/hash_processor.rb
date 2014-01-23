module Perf
  module HashProcessor
    def process_hash(hash)
      hash.inject({}){|h, (k, v)| h[k] = process_hash_value(v); h}
    end

    def process_hash_value(v)
      v = v.to_proc.call if v.respond_to?(:to_proc)
      v
    end
  end
end