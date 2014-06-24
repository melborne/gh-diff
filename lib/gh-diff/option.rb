require "dotenv"

module GhDiff
  class Option
    attr_reader :opts
    def initialize(opts)
      @opts = down_symbolize_key(opts)
    end

    def update(opts)
      @opts.update(down_symbolize_key opts)
    end

    def dotenv
      @dotenv ||= down_symbolize_key(Dotenv.load)
    end

    # returns: ENV variables prefixed with 'GH_'(default)
    #          and variables defined in dotenv file.
    def env(prefix='GH_')
      @envs ||= begin
        envs = ENV.select { |env| env.start_with? prefix }
                  .map { |k, v| [k.sub(/^#{prefix}/, ''), v] }
        down_symbolize_key(envs)
      end
      @envs.merge(dotenv)
    end

    def with_env(prefix='GH_')
      env(prefix).merge(@opts)
    end

    private
    def down_symbolize_key(opts)
      opts.inject({}) do |h, (k, v)|
        h[k.to_s.downcase.intern] = v; h
      end
    end
  end
end
