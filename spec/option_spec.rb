require 'spec_helper'

describe GhDiff::Option do
  before(:all) do
    @dotenv = File.join(source_root, ".env")
    File.write(@dotenv, <<-EOS)
REPO=jekyll/jekyll
DIR=site
    EOS
    @dotenv_opts = {'repo' => 'jekyll/jekyll', 'dir' => 'site'}
    @global_opts = {'token' => '12345'}
    ENV['GH_TOKEN'] = '12345'
    ENV['GH_DIR'] = 'lib'
  end

  after(:all) do
    FileUtils.rm(@dotenv) if File.exist?(@dotenv)
  end

  let(:option) do
    GhDiff::Option.new({user:'Charlie'})
  end

  describe "#dotenv" do
    it "returns dotenv variables" do
      expect(option.dotenv).to eq(@dotenv_opts)
    end
  end

  describe "#env" do
    it "returns env variables" do
      opts = @global_opts.merge(@dotenv_opts)
      expect(option.env).to eq(opts)
    end
  end

  describe "#with_env" do
    it "returns options merged with env variables" do
      opts = @global_opts.merge(@dotenv_opts).merge('user' => 'Charlie')
      expect(option.with_env).to eq(opts)
    end
  end
end