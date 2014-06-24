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
      f = get_contents(@repo, path, @revision)
      Base64.decode64(f.content)
    end

    def diff(file1, file2=file1, commentout:false,
                                 comment_tag:'original', **opts)
      opts = {context:3}.merge(opts)
      if File.directory?(file1)
        local_files = Dir.glob("#{file1}/*")
        diffs = {}
        local_files.map do |file|
          Thread.new(file) do |_file|
            diffs[_file] = _diff(_file, _file, commentout, comment_tag, opts)
          end
        end.each(&:join)
        diffs
      else
        _diff(file1, file2, commentout, comment_tag, opts)
      end
    end

    def dir_diff(dir)
      local_files = Dir.glob("#{dir}/*").map { |f| File.basename f }
      remote_path = build_path(@dir, dir)
      remote_files = get_contents(@repo, remote_path, @revision).map(&:name)
      added = remote_files - local_files
      removed = local_files - remote_files
      [added, removed]
    end

    def ref(ref='master')
      case ref
      when /^v\d/
        get_ref(@repo, "tags/#{ref}")
      else
        get_ref(@repo, "heads/#{ref}")
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

    def get_contents(repo, path, ref)
      Octokit.contents(repo, path:path, ref:ref)
    end

    def get_ref(repo, ref)
      Octokit.ref(repo, ref)
    end
  end
end
