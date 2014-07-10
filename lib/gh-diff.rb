require "gh-diff/version"
require "gh-diff/cli"
require "gh-diff/option"
require "gh-diff/auth"

require "base64"
require "octokit"
require "diffy"
require "togglate"

module GhDiff
  class RepositoryNameError < StandardError; end
  class Diff
    attr_accessor :repo, :revision, :dir
    def initialize(repo, revision:'master', dir:nil)
      raise RepositoryNameError if repo.nil? || repo.empty?
      @repo = repo
      @revision = revision
      @dir = dir
    end

    def get(file, repo:@repo, revision:@revision, dir:@dir, **opts)
      path = build_path(dir, file)
      f = get_contents(repo, path, revision)
      Base64.decode64(f.content)
    end

    def diff(file1, file2=file1, commentout:false,
                                 comment_tag:'original', **opts)
      opts = {context:3}.merge(opts)
      is_dir = File.directory?(file1)

      file_pairs = build_file_pairs(file1, file2, dir:is_dir)
      diffs = parallel(file_pairs) { |file1, file2|
                _diff(file1, file2, commentout, comment_tag, opts) }
      diffs
    end

    def dir_diff(directory, repo:@repo, revision:@revision, dir:@dir)
      local_files = Dir.glob("#{directory}/*").map { |f| File.basename f }
      remote_path = build_path(dir, directory)
      remote_files = get_contents(repo, remote_path, revision).map(&:name)
      added = remote_files - local_files
      removed = local_files - remote_files
      [added, removed]
    end

    def ref(ref='master', repo:@repo)
      type = ref.match(/^v\d/) ? :tags : :heads
      get_ref(repo, "#{type}/#{ref}")
    rescue Octokit::NotFound
      {ref:'', object:{sha:ref}}
    end

    private
    def build_path(dir, file)
      (dir.nil? || dir.empty?) ? file : File.join(dir, file)
    end

    def _diff(file1, file2, commentout, comment_tag, opts)
      local = File.read(file1)
      local = Togglate.commentout(local, tag:comment_tag)[0] if commentout
      remote = get(file2, opts)
      Diffy::Diff.new(local, remote, opts)
    rescue Errno::ENOENT
      :LocalNotFound
    rescue Octokit::NotFound
      :RemoteNotFound
    end

    def get_contents(repo, path, ref)
      Octokit.contents(repo, path:path, ref:ref)
    end

    def get_ref(repo, ref)
      Octokit.ref(repo, ref)
    end

    def build_file_pairs(file1, file2, dir:false)
      if dir
        fs = Dir.glob("#{file1}/*").select { |f| File.file? f }
        fs.zip(fs)
      else
        [[file1, file2]]
      end
    end

    def parallel(items)
      result = {}
      items.map do |item1, item2|
        Thread.new(item1, item2) do |_item1, _item2|
          result[[_item1, _item2]] = yield(_item1, _item2)
        end
      end.each(&:join)
      result
    end
  end
end
