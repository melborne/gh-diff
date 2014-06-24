require "base64"

require "thor"
require "octokit"
require "dotenv"

module GhDiff
  ENV_KEYS = %w(USERNAME PASSOWRD TOKEN REPO REVISION PATH SAVE_PATH)
  class CLI < Thor
    class_option :repo, aliases:'-g', desc:'target repository'
    class_option :revision, aliases:'-r', default:'master', desc:'target revision'
    class_option :dir, aliases:'-p', desc:'target file directory'

    desc "get FILE", "Get FILE content from github repository"
    option :save, aliases:'-s', default:false, type: :boolean
    option :save_path, default:"diff", desc:'save path'
    option :stdout, default:true, type: :boolean, desc:'output file content in terminal'
    def get(file)
      opts = Option.new(options).with_env
      gh = Diff.new(opts[:repo], revision:opts[:revision], dir:opts[:dir])
      content = gh.get(file)

      if opts[:save]
        save(content, build_path(opts[:save_path], file))
      elsif opts[:stdout]
        print content
      end
      content
    rescue ::Octokit::NotFound
      puts "File not found at remote: '#{build_path(opts[:dir], file)}'"
      exit(1)
    rescue => e
      puts "something go wrong: #{e}"
      exit(1)
    end

    no_tasks do
      def build_path(dir, file)
        if dir.nil? || dir.empty?
          file
        else
          File.join(dir, file)
        end
      end

      def mkdir(dir)
        FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      end

      def save(content, path)
        mkdir(File.dirname path)
        File.write(path, content)
      end
    end
  end
end
