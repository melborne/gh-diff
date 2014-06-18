require "base64"

require "thor"
require "octokit"

module GhDiff
  class CLI < Thor
    class_option :repo, aliases:'-g', desc:'target repository'
    class_option :revision, aliases:'-r', default:'master', desc:'target revision'
    class_option :path, aliases:'-p', default:"", desc:'target file path'

    desc "get FILE", "Get FILE content from github repository"
    option :save, aliases:'-s', default:false, type: :boolean
    option :save_path, default:"diff", desc:'save path'
    option :stdout, default:true, type: :boolean, desc:'output file content in terminal'
    def get(file)
      content = get_content( options[:repo],
                             path:File.join(options[:path], file),
                             ref:options[:revision] )

      if options[:save]
        save(content, File.join(options[:save_path], file))
      elsif options[:stdout]
        print content
      end
      content
    rescue ::Octokit::NotFound
      puts "File not found at remote: '#{path}'"
      exit(1)
    end

    no_tasks do
      def get_content(repo, opts)
        f = Octokit.contents(repo, opts)
        Base64.decode64(f.content)
      end

      def mkdir(dir)
        FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      end

      def save(content, path)
        mkdir(File.dirname path)
        File.write(path, content)
      end
    end
  end
end