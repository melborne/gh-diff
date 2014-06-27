require "thor"

module GhDiff
  ENV_KEYS = %w(USERNAME PASSOWRD TOKEN REPO REVISION PATH SAVE_PATH)
  class CLI < Thor
    class_option :repo, aliases:'-g', desc:'target repository'
    class_option :revision, aliases:'-r', default:'master', desc:'target revision'
    class_option :dir, aliases:'-p', desc:'target file directory'
    class_option :username, desc:'github username'
    class_option :password, desc:'github password'
    class_option :oauth, desc:'github oauth token'

    desc "get FILE", "Get FILE content from github repository"
    def get(file)
      opts = Option.new(options).with_env
      github_auth(opts[:username], opts[:password], opts[:oauth])

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
    option :commentout, aliases:'-c', default:true, type: :boolean
    option :comment_tag, aliases:'-t', default:'original'
    option :format, aliases:'-f', default:'color'
    def diff(file1, file2=file1)
      opts = Option.new(options).with_env
      github_auth(opts[:username], opts[:password], opts[:oauth])

      gh = Diff.new(opts[:repo], revision:opts[:revision], dir:opts[:dir])
      diffs = gh.diff(file1, file2, commentout:opts[:commentout],
                                 comment_tag:opts[:comment_tag])
      diffs.each do |file, diff|
        print file, "\n\n"
        print diff.to_s(opts[:format].intern)
      end
    end

    desc "dir_diff DIRECTORY", "Print added and removed files in remote repository"
    def dir_diff(dir)
      opts = Option.new(options).with_env
      github_auth(opts[:username], opts[:password], opts[:oauth])

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

    @@login = nil
    no_tasks do
      def github_auth(username, password, oauth)
        return true if @@login
        return false unless oauth || [username, password].all?

        @@login = Auth[username:username, password:password, oauth:oauth]
      rescue ::Octokit::Unauthorized
        puts "Bad Credentials"
        exit(1)
      end
    end
  end
end
