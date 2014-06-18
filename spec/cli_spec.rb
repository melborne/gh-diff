require 'spec_helper'

describe GhDiff::CLI do
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
        GhDiff::CLI.start(['get', 'docs/quickstart.md',
                           '--repo=jekyll/jekyll', '--path=site'])
        expect($stdout.string).to match(/title: Quick-start guide/)
      end
    end

    it "saves a file content" do
      VCR.use_cassette 'quickstart' do
        GhDiff::CLI.start(['get', 'docs/quickstart.md',
                           '--repo=jekyll/jekyll', '--path=site',
                           '--save'])
        path = 'diff/docs/quickstart.md'
        expect(File.exist? path).to be true
        expect(File.read path).to match(/title: Quick-start guide/)
      end
    end
  end
end
