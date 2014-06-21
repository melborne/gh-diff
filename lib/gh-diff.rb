require "gh-diff/version"
require "gh-diff/cli"
require "gh-diff/option"

require "base64"
require "diffy"

module GhDiff
  class Diff
    attr_accessor :repo, :revision, :dir
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

    def diff(file1, file2=file1, opts={})
      opts = {context:3}.merge(opts)
      local = File.read(file1)
      remote = get(file2)
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
