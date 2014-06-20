require "gh-diff/version"
require "gh-diff/cli"

require "base64"
require "diffy"

module GhDiff
  class GhDiff
    def initialize(repo, revision:'master', dir:nil)
      @repo = repo
      @revision = revision
      @dir = dir
    end

    def get(file)
      path = build_path(@dir, file)
      f = Octokit.contents(@repo, path:path, ref:@revision)
      Base64.decode64(f.content)
    end

    def diff(file, opts={context:3})
      local = File.read(file)
      remote = get(file)
      Diffy::Diff.new(local, remote, opts)
    end

    private
    def build_path(dir, file)
      if dir.nil? || dir.empty?
        file
      else
        File.join(dir, file)
      end
    end
  end
end
