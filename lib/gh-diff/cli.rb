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
    def get(file)
      opts = Option.new(options).with_env
      gh = Diff.new(opts[:repo], revision:opts[:revision], dir:opts[:dir])
      print gh.get(file)
    rescue ::Octokit::NotFound
      path = (dir=opts[:dir]) ? "#{dir}/#{file}" : file
      puts "File not found at remote: '#{path}'"
      exit(1)
    rescue => e
      puts "something go wrong: #{e}"
      exit(1)
    end

    no_tasks do
    end
  end
end
