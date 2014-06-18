require "base64"

require "thor"
require "octokit"

module GhDiff
  class CLI < Thor
    class_option :repo, aliases:'-g', desc:'target repository'
    class_option :revision, aliases:'-r', default:'master', desc:'target revision'
    class_option :path, aliases:'-p', default:"", desc:'target file path'

    desc "get FILE", "Get FILE content from github repository"
    def get(file)
      path = File.join(options[:path], file)
      content = get_content(options[:repo], path:path, ref:options[:revision])
      print content
    end

    no_tasks do
      def get_content(repo, opts)
        f = Octokit.contents(repo, opts)
        Base64.decode64(f.content)
      end
    end
  end
end