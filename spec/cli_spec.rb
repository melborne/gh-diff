require 'spec_helper'

describe GhDiff::CLI do
  before(:all) do
    @diff_result =<<-EOS
 ---
 layout: docs
 title: Quick-start guide
-prev_section: old-home
-next_section: old-installation
+prev_section: home
+next_section: installation
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
                        --repo=jekyll/jekyll --dir=site)
        GhDiff::CLI.start
        expect($stdout.string).to eq @diff_result
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
