require 'spec_helper'

describe GhDiff::CLI do
  before(:all) do
    @diff_result =<<-EOS
docs/quickstart.md

 ---
 layout: docs
 title: Quick-start guide
\e[31m-prev_section: old-home\e[0m
\e[31m-next_section: old-installation\e[0m
\e[32m+prev_section: home\e[0m
\e[32m+next_section: installation\e[0m
 permalink: /docs/quickstart/
 ---
 
    EOS
  end

  before do
    $stdout, $stderr = StringIO.new, StringIO.new
    @save_dir = File.join(source_root, "diff")
    Octokit.reset!
  end

  after do
    $stdout, $stderr = STDIN, STDERR
    FileUtils.rm_r(@save_dir) if Dir.exist?(@save_dir)
  end

  describe "get" do
    it "prints a file content" do
      VCR.use_cassette 'quickstart' do
        ARGV.replace %w(get docs/quickstart.md
                        --repo=jekyll/jekyll --dir=site)
        GhDiff::CLI.start
        expect($stdout.string).to match(/title: Quick-start guide/)
      end
    end

    it "raises an error when a file not found" do
      VCR.use_cassette 'nonexist' do
        ARGV.replace %w(get docs/nonexist.md --repo=jekyll/jekyll)
        expect { GhDiff::CLI.start }.to raise_error(SystemExit)
      end
    end
  end

  describe "diff" do
    it "prints diff" do
      VCR.use_cassette('quickstart') do
        ARGV.replace %w(diff docs/quickstart.md
                        --repo=jekyll/jekyll --dir=site
                        --commentout=false)
        GhDiff::CLI.start
        expect($stdout.string).to eq @diff_result
      end
    end

    context "with save option" do
      it "saves a diff file" do
        VCR.use_cassette('save-diff') do
          ARGV.replace %w(diff docs/quickstart.md
                        --repo=jekyll/jekyll --dir=site
                        --no-commentout --save)
          GhDiff::CLI.start
          path = 'diff/docs/quickstart.diff'
          expect($stdout.string).to match(/Diff saved at '#{path}'/)
          expect(File.exist? path).to be true
          expect(File.read path).to match(/-prev_section: old-home/)
        end
      end

      it "saves diff files" do
        VCR.use_cassette('save-diffs') do
          ARGV.replace %w(diff docs
                        --repo=jekyll/jekyll --dir=site
                        --no-commentout --save)
          GhDiff::CLI.start
          paths = ["diff/docs/quickstart.diff", "diff/docs/migrations.diff"]
          paths.each { |f| expect(File.exist? f).to be true }
          expect(File.read paths[0]).to match(/layout: docs.*Quick-start guide/m)
          expect(File.read paths[1]).to match(/add this line.*switching/m)
        end
      end
    end
  end

  describe "dir_diff" do
    it "print added and removed files at remote repository" do
      VCR.use_cassette('dir') do
        ARGV.replace %w(dir_diff docs
                        --repo=jekyll/jekyll --dir=site)
        GhDiff::CLI.start
        expect($stdout.string).to match(/New files:.*collections.md/m)
      end
    end
  end
end
