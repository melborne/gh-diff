require 'spec_helper'

describe GhDiff do
  it 'has a version number' do
    expect(GhDiff::VERSION).not_to be nil
  end
end

describe GhDiff::GhDiff do
  let(:gh) { GhDiff::GhDiff.new 'jekyll/jekyll', revision:'master', dir:'site' }

  describe "get" do
    it "returns file content" do
      VCR.use_cassette('quickstart') do
        content = gh.get('docs/quickstart.md')
        expect(content).to match(/title: Quick-start guide/)
      end
    end
  end
end
