require "thor"

module GhDiff
  class CLI < Thor
    class_option :repo,
                  aliases:'-g',
                  desc:'target repository'
    class_option :revision,
                  aliases:'-r',
                  default:'master',
                  desc:'target revision'
    class_option :dir,
                  aliases:'-p',
                  desc:'target remote directory'
    class_option :username,
                  desc:'github username'
    class_option :password,
                  desc:'github password'
    class_option :token,
                  desc:'github API access token'

    desc "get FILE", "Get FILE content from github repository"
    option :ref,
           aliases:'-f',
           default:false,
           type: :boolean,
           desc:'Print reference data'
    def get(file)
      opts = Option.new(options).with_env
      github_auth(opts[:username], opts[:password], opts[:token])

      gh = init_ghdiff(opts[:repo], opts[:revision], opts[:dir])
      if opts[:ref]
        ref = gh.ref(opts[:revision], repo:opts[:repo])
        print ref_format(ref)
      end
      print gh.get(file)
    rescue ::Octokit::NotFound
      path = (dir=opts[:dir]) ? "#{dir}/#{file}" : file
      puts "File not found at remote: '#{path}'"
      exit(1)
    rescue => e
      puts "something go wrong: #{e}"
      exit(1)
    end

    desc "diff LOCAL_FILE [REMOTE_FILE]", "Compare FILE(s) between local and remote repository. LOCAL_FILE can be DIRECTORY."
    option :commentout,
            aliases:'-c',
            default:false,
            type: :boolean,
            desc:"compare html-commented texts in local file(s) with the remote"
    option :comment_tag,
            aliases:'-t',
            default:'original'
    option :format,
            aliases:'-f',
            default:'color',
            desc:"output format: any of text, color, html or html_simple"
    option :save,
            aliases:'-s',
            default:false,
            type: :boolean
    option :save_dir,
            default:'diff',
            desc:'save directory'
    option :name_only,
            default:true,
            type: :boolean
    def diff(file1, file2=file1)
      opts = Option.new(options).with_env
      github_auth(opts[:username], opts[:password], opts[:token])

      gh = init_ghdiff(opts[:repo], opts[:revision], opts[:dir])
      diffs = gh.diff(file1, file2, commentout:opts[:commentout],
                                    comment_tag:opts[:comment_tag])

      ref = gh.ref(opts[:revision], repo:opts[:repo])

      diffs.each do |(f1, f2), diff|
        next if file_not_found?(f1, f2, diff)
        header = "#{ref_format(ref)}--- #{f1}\n+++ #{f2}\n\n"
        diff_form = "#{f1} <-> #{f2} [%s:%s]" %
                    [ref[:object][:sha][0,7], ref[:ref].match(/\w+$/).to_s]

        if opts[:save]
          format = opts[:format]=='color' ? :text : opts[:format]
          content = diff.to_s(format)
          unless content.empty?
            save(header + content, opts[:save_dir], f1)
          else
            print "\e[32mno Diff on\e[0m #{diff_form}\n"
          end
        else
          content = diff.to_s(:text)
          unless content.empty?
            if opts[:name_only]
              printf "\e[31mDiff found on\e[0m #{diff_form}\n"
            else
              print header
              print diff.to_s(opts[:format])
            end
          else
            print "\e[32mno Diff on\e[0m #{diff_form}\n"
          end
        end
      end
    end

    desc "dir_diff DIRECTORY", "Print added and removed files in remote repository"
    option :save,
            aliases:'-s',
            default:false,
            type: :boolean
    option :save_dir,
            default:'diff',
            desc:'save directory'
    option :ref,
           aliases:'-f',
           default:false,
           type: :boolean,
           desc:'Add reference data into YAML front-matter of a file to be saved'
    def dir_diff(dir)
      opts = Option.new(options).with_env
      github_auth(opts[:username], opts[:password], opts[:token])

      gh = init_ghdiff(opts[:repo], opts[:revision], opts[:dir])
      added, removed = gh.dir_diff(dir)
      if [added, removed].all?(&:empty?)
        puts "\e[33mNothing changed\e[0m"
      else
        if added.any?
          puts "\e[33mNew files:\e[0m"
          puts added.map { |f| "  \e[32m" + f + "\e[0m" }
          if opts[:save]
            added.each do |f|
              path = File.join(dir, f)
              content = gh.get(path)
              if opts[:ref]
                content = add_reference(gh, opts[:revision],
                                            opts[:repo], content)
              end
              unless content.empty?
                save(content, opts[:save_dir], path, File.extname(path))
              end
            end
          end
        end
        if removed.any?
          puts "\e[33mRemoved files:\e[0m"
          puts removed.map { |f| "  \e[31m" + f + "\e[0m" }
          if opts[:save]
            removed.each do |f|
              path = File.join(dir, f)
              content = "---\nFile: #{path}\nStatus: file deleted\n---\n"
              if opts[:ref]
                content = add_reference(gh, opts[:revision],
                                            opts[:repo], content)
              end
              save(content, opts[:save_dir], path, '.delete')
            end
          end
        end
      end
    end

    desc "version", "Show gh-diff version"
    def version
      puts "gh-diff #{GhDiff::VERSION} (c) 2014 kyoendo"
    end
    map "-v" => :version

    @@login = nil
    no_tasks do
      def init_ghdiff(repo, rev, dir)
        Diff.new(repo, revision:rev, dir:dir)
      rescue GhDiff::RepositoryNameError
        puts "Repository should be specified with 'repo' option"
        exit(1)
      end

      def github_auth(username, password, token)
        return true if @@login
        return false unless token || [username, password].all?

        @@login = Auth[username:username, password:password, token:token]
      rescue ::Octokit::Unauthorized
        puts "Bad Credentials"
        exit(1)
      end

      def mkdir(dir)
        FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      end

      def save(content, save_dir, file, ext='.diff')
        dir = (d=File.dirname(file))=='.' ? '' : d
        file = File.basename(file, '.*') + ext
        path = File.join(save_dir, dir, file)
        mkdir(File.dirname path)
        File.write(path, content)
        print "\e[32mFile saved at '#{path}'\e[0m\n"
      end

      def add_reference(ghdiff, revision, repo, content)
        ref = ghdiff.ref(revision, repo:repo)
        yfm_re = /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
        if md = content.match(yfm_re)
          md[1] + ref_format(ref, 'base_revision:') + md[2] + md.post_match
        else
          ref_format(ref) + content
        end
      end

      def ref_format(ref, head="Base revision:")
        "#{head} #{ref[:object][:sha]}[#{ref[:ref]}]\n"
      end

      def file_not_found?(f1, f2, content)
        case content
        when :RemoteNotFound
          print "\e[31m#{f2} not found on remote\e[0m\n"
          true
        when :LocalNotFound
          print "\e[31m#{f1} not found on local\e[0m\n"
          true
        else
          false
        end
      end
    end
  end
end
