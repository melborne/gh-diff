require "dotenv"

module GhDiff
  class Option
    attr_reader :opts
    def initialize(opts)
      @opts = downstringfy_key(opts)
    end

    def update(opts)
      @opts.update(downstringfy_key opts)
    end

    def dotenv
      @dotenv ||= begin
        Dotenv.load.inject({}) do |h, (k, v)|
          h[k.downcase] = v; h
        end
      end
    end

    # returns: ENV variables prefixed with 'GH_'(default)
    #          and variables defined in dotenv file.
    def env(prefix='GH_')
      @envs ||= begin
        ENV.select { |env| env.start_with? prefix }
           .inject({}) do |h, (k, v)|
             h[k.sub(/^#{prefix}/, '').downcase] = v; h
           end
      end
      @envs.merge(dotenv)
    end

    def with_env(prefix='GH_')
      env(prefix).merge(@opts)
    end

    private
    def downstringfy_key(opts)
      opts.inject({}) do |h, (k, v)|
        h[k.to_s.downcase] = v; h
      end
    end
  end
end
