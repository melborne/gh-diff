require 'spec_helper'

describe GhDiff do
  it 'has a version number' do
    expect(GhDiff::VERSION).not_to be nil
  end
end

describe GhDiff::Diff do
  let(:gh) do
    GhDiff::Diff.new 'jekyll/jekyll', revision:'master', dir:'site'
  end

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

  describe "get" do
    it "returns a file content" do
      VCR.use_cassette('quickstart') do
        content = gh.get('docs/quickstart.md')
        expect(content).to match(/title: Quick-start guide/)
      end
    end
  end

  describe "diff" do
    it "compares files" do
      VCR.use_cassette('quickstart') do
        diff = gh.diff('docs/quickstart.md')
        expect(diff).to be_instance_of Diffy::Diff
        expect(diff.to_s).to eq @diff_result
      end
    end

    context "with commentout option" do
      it "compares with texts only in comment tags" do
        VCR.use_cassette('quickstart') do
          diff = gh.diff('docs/quickstart.ja.md',
                         'docs/quickstart.md', commentout:true)
          expect(diff.to_s).to eq @diff_result
        end
      end
    end
  end
end

