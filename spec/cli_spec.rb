require 'spec_helper'

describe GhDiff::CLI do
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
end
