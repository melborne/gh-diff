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

    @diff_result2 =<<-EOS
 permalink: /docs/migrations/
 ---
 
-add this line.
-
 If you’re switching to Jekyll from another blogging system, Jekyll’s importers
 can help you with the move. To learn more about importing your site to Jekyll,
 visit our [`jekyll-import` docs site](http://import.jekyllrb.com/docs/home/).
    EOS
  end

  before do
    $stdout, $stderr = StringIO.new, StringIO.new
    @save_dir = File.join(source_root, "diff")
    @original_dir = Dir.pwd
    Dir.chdir(source_root)
    Octokit.reset!
  end

  after do
    $stdout, $stderr = STDIN, STDERR
    FileUtils.rm_r(@save_dir) if Dir.exist?(@save_dir)
    Dir.chdir(@original_dir)
  end

  describe "#get" do
    it "returns a file content" do
      VCR.use_cassette('quickstart') do
        content = gh.get('docs/quickstart.md')
        expect(content).to match(/title: Quick-start guide/)
      end
    end
  end

  describe "#diff" do
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
          diff = gh.diff('ja-docs/quickstart.ja.md',
                         'docs/quickstart.md', commentout:true)
          expect(diff.to_s).to eq @diff_result
        end
      end
    end

    context "pass a directory" do
      it "compares files in the directory" do
        VCR.use_cassette('docs') do
          res = gh.diff('docs')
          files = res.keys
          diffs = res.values.sort_by(&:to_s)
          expect(files).to match_array ["docs/migrations.md", "docs/quickstart.md"]
          expect(diffs.all?{ |diff| Diffy::Diff === diff }).to be true
          expect(diffs[0].to_s).to eq @diff_result
          expect(diffs[1].to_s).to eq @diff_result2
        end
      end
    end

    context "with save option" do
      it "saves a diff file" do
        VCR.use_cassette('save-diff') do
          path = 'diff/docs/quickstart.diff'
          diff = gh.diff('docs/quickstart.md',
                         save_path:path)
          expect($stdout.string).to match(/Diff saved at '#{path}'/)
          expect(File.exist? path).to be true
          expect(File.read path).to eq @diff_result
        end
      end

      it "saves diff files" do
        VCR.use_cassette('save-diffs') do
          path = 'diff/docs2'
          files = ["diff/docs2/migrations.diff", "diff/docs2/quickstart.diff"]
          diff = gh.diff('docs', save_path:path)
          files.each { |f| expect(File.exist? f).to be true }
          expect(File.read files[1]).to eq @diff_result
          expect(File.read files[0]).to eq @diff_result2
        end
      end
    end
  end

  describe "#dir_diff" do
    it "compares file exsistence in target directory" do
      VCR.use_cassette('dir') do
        added, removed = gh.dir_diff('docs')
        expect(added).to include('collections.md', 'heroku.md')
        expect(added).not_to include('quickstart.md', 'migrations.md')
        expect(removed).to be_empty
      end
    end
  end

  describe "#ref" do
    it "gets a reference data form the id" do
      VCR.use_cassette('ref') do
        ref = gh.ref('master')
        expect(ref[:ref]).to eq "refs/heads/master"
        expect(ref[:object][:sha]).to include "e345ceb01ac61"
      end
    end

    it "takes a tag as ref id" do
      VCR.use_cassette('ref-tag') do
        ref = gh.ref('v1.0.0')
        expect(ref[:ref]).to eq "refs/tags/v1.0.0"
      end
    end
  end
end
