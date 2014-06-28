$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'gh-diff'
require "stringio"
require "fileutils"
require "webmock"
require "vcr"
require "tildoc"

module Helpers
  def source_root
    File.join(File.dirname(__FILE__), 'fixtures')
  end
end

Resource = Struct.new(:content, :sha, :path, :url)

RSpec.configure do |c|
  c.include Helpers
  c.before do
    @original_dir = Dir.pwd
    Dir.chdir(source_root)
  end

  c.after do
    Dir.chdir(@original_dir)
  end
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
end