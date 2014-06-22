require "gh-diff/version"
require "gh-diff/cli"
require "gh-diff/option"

require "base64"
require "diffy"
require "togglate"

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

    def diff(file1, file2=file1,
             commentout:false, comment_tag:'original', **opts)
      opts = {context:3}.merge(opts)
      ts = []
      if File.directory?(file1)
        local_files = Dir.glob("#{file1}/*")
        diffs = []
        local_files.map do |file|
          Thread.new(file) do |_file|
            diffs << _diff(_file, _file, commentout, comment_tag, opts)
          end
        end.each(&:join)
        diffs
      else
        _diff(file1, file2, commentout, comment_tag, opts)
      end
    end

    private
    def build_path(dir, file)
      if dir.nil? || dir.empty?
        file
      else
        File.join(dir, file)
      end
    end

    def _diff(file1, file2, commentout, comment_tag, opts)
      local = File.read(file1)
      local = Togglate.commentout(local, tag:comment_tag)[0] if commentout
      remote = get(file2)
      Diffy::Diff.new(local, remote, opts)
    end
  end
end
