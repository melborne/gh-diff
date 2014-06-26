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

    desc "diff FILE", "Compare FILE between local and remote repository"
    def diff(file)
      opts = Option.new(options).with_env
      gh = Diff.new(opts[:repo], revision:opts[:revision], dir:opts[:dir])
      print gh.diff(file)
    end

    desc "dir_diff DIRECTORY", "Print added and removed files in remote repository"
    def dir_diff(dir)
      opts = Option.new(options).with_env
      gh = Diff.new(opts[:repo], revision:opts[:revision], dir:opts[:dir])
      added, removed = gh.dir_diff(dir)
      if [added, removed].all?(&:empty?)
        puts "Nothing changed"
      else
        if added.any?
          puts "New files:"
          puts added.map { |f| "  " + f }
        end
        if removed.any?
          puts "Removed files:"
          puts removed.map { |f| "  " + f }
        end
      end
    end

    no_tasks do
    end
  end
end
