require 'spec_helper'

describe GhDiff::CLI do
  before(:all) do
    @dotenv = File.join(source_root, ".env")
    File.write(@dotenv, <<-EOS)
REPO=jekyll/jekyll
PATH=site
    EOS
  end

  after(:all) do
    FileUtils.rm(@dotenv) if File.exist?(@dotenv)
  end

  before do
    $stdout, $stderr = StringIO.new, StringIO.new
    @original_dir = Dir.pwd
    @save_dir = File.join(source_root, "diff")
    Dir.chdir(source_root)
    Octokit.reset!
  end

  after do
    $stdout, $stderr = STDIN, STDERR
    FileUtils.rm_r(@save_dir) if Dir.exist?(@save_dir)
    Dir.chdir(@original_dir)
  end

  describe "get" do
    it "prints a file content" do
      VCR.use_cassette 'quickstart' do
        ARGV.replace %w(get docs/quickstart.md
                        --repo=jekyll/jekyll --path=site)
        GhDiff::CLI.start
        expect($stdout.string).to match(/title: Quick-start guide/)
      end
    end

    it "saves a file content" do
      VCR.use_cassette 'quickstart' do
        ARGV.replace %w(get docs/quickstart.md
                        --repo=jekyll/jekyll --path=site --save)
        path = 'diff/docs/quickstart.md'
        expect(GhDiff::CLI.start).to match(/title: Quick-start guide/)
        expect(File.exist? path).to be true
        expect(File.read path).to match(/title: Quick-start guide/)
      end
    end

  end

  describe ".env" do
    it "reads options from .env file" do
      VCR.use_cassette 'quickstart' do
        ARGV.replace %w(get docs/quickstart.md)
        GhDiff::CLI.start
        expect($stdout.string).to match(/title: Quick-start guide/)
      end
    end
  end
end
