require 'spec_helper'

describe GhDiff::CLI do
  before do
    $stdout, $stderr = StringIO.new, StringIO.new
    @original_dir = Dir.pwd
    Dir.chdir(source_root)
  end

  after do
    $stdout, $stderr = STDIN, STDERR
    Dir.chdir(@original_dir)
  end

  describe "get" do
    GhDiff::CLI.start(['get', 'docs/quickstart.md', '--repo=jekyll/jekyll', '--revision=master', '--path=site'])
    expect($stdout.string).to match(/title: Quick-start guide/)
  end
end
