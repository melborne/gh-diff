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
      save_path = opts.delete(:save_path)
      files =
        if is_dir = File.directory?(file1)
          fs = Dir.glob("#{file1}/*")
          fs.zip(fs)
        else
          [[file1, file2]]
        end
      diffs = parallel(files) { |file1, file2|
                _diff(file1, file2, commentout, comment_tag, opts) }
      if save_path
        diffs.each { |file, content| save(content, save_path, file, dir:is_dir) }
      else
        is_dir ? diffs : diffs[file1]
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

    def mkdir(dir)
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
    end

    def save(content, save_path, file, dir:false)
      directory = dir ? save_path : File.dirname(save_path)
      path = File.join(directory, File.basename(file, '.*') + '.diff')
      mkdir(File.dirname path)
      File.write(path, content)
      print "Diff saved at '#{path}'\n"
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

    def parallel(items)
      result = {}
      items.map do |item1, item2|
        Thread.new(item1, item2) do |_item1, _item2|
          result[_item1] = yield(_item1, _item2)
        end
      end.each(&:join)
      result
    end
  end
end
