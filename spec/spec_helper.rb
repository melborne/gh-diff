$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'gh-diff'
require "stringio"

module Helpers
  def source_root
    File.join(File.dirname(__FILE__), 'fixtures')
  end
end

RSpec.configure do |c|
  c.include Helpers
  c.before do
    # FakeWeb.clean_registry
    # body = File.read(File.join(source_root, 'quickstart.md'))
    # FakeWeb.register_uri(:get, %r(https://api\.github\.com), body:body)
  end
end