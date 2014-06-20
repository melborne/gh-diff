require "gh-diff/version"
require "gh-diff/cli"

require "base64"

module GhDiff
  class GhDiff
    def initialize(repo, opts)
      @repo = repo
      @opts = opts
    end

    def get(file)
      path, ref = build_path(@opts[:dir], file), @opts[:revision]
      f = Octokit.contents(@repo, path:path, ref:ref)
      Base64.decode64(f.content)
    end

    def build_path(dir, file)
      if dir.nil? || dir.empty?
        file
      else
        File.join(dir, file)
      end
    end
  end
end
