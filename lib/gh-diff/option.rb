require "dotenv"

module GhDiff
  class Option
    def initialize(opts)
      @opts = opts.inject({}) do |h, (k, v)|
        h[k.to_s] = v; h
      end
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
      @opts.merge(env(prefix))
    end

    def update_options_with_dotenv(options)
      @@dotenv ||= Dotenv.load
      envs = ENV.select { |env| env.start_with?('GH_') }
                .inject({}) { |h, (k, v)| h[k.sub(/^GH_/, '')] = v; h }
      envs.update(@@dotenv)
      envs.select! { |env| ENV_KEYS.include? env }
      envs.each do |key, val|
        env = key.downcase
        options.update(env => val) unless options[env]
      end
      options
    end
    
  end
end