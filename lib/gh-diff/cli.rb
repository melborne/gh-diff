require "base64"

require "thor"
require "octokit"
require "dotenv"

module GhDiff
  ENV_KEYS = %w(USERNAME PASSOWRD TOKEN REPO REVISION PATH)
  class CLI < Thor
    @@dotenv = nil
    class_option :repo, aliases:'-g', desc:'target repository'
    class_option :revision, aliases:'-r', default:'master', desc:'target revision'
    class_option :path, aliases:'-p', desc:'target file path'

    desc "get FILE", "Get FILE content from github repository"
    option :save, aliases:'-s', default:false, type: :boolean
    option :save_path, default:"diff", desc:'save path'
    option :stdout, default:true, type: :boolean, desc:'output file content in terminal'
    def get(file)
      opts = update_options_with_dotenv(options.dup)
      path = File.join(opts[:path], file)
      content = get_content( opts[:repo],
                             path:path,
                             ref:opts[:revision] )

      if opts[:save]
        save(content, File.join(opts[:save_path], file))
      elsif opts[:stdout]
        print content
      end
      content
    rescue ::Octokit::NotFound
      puts "File not found at remote: '#{path}'"
      exit(1)
    rescue => e
      puts "something go wrong: #{e}"
      exit(1)
    end

    no_tasks do
      def get_content(repo, opts)
        f = Octokit.contents(repo, opts)
        Base64.decode64(f.content)
      end

      def mkdir(dir)
        FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      end

      def save(content, path)
        mkdir(File.dirname path)
        File.write(path, content)
      end

      def update_options_with_dotenv(options)
        @@dotenv ||= Dotenv.load
        # env = ENV.select { |env| env.start_with?('GH_') }
        #          .inject({}) { |h, (k, v)| h[k.sub(/^GH_/, '')] = v; h}
        @@dotenv.each do |key, val|
          env = key.downcase
          options.update(env => val) unless options[env]
        end
        options
      end
    end
  end
end
