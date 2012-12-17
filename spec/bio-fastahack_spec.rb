require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'tmpdir'

describe "BioFastahack" do
  it "should retrieve all seqs" do
    test_wrapper %w(>12 ATG >13 AGT).join("\n") do
      expected = {
        '12' => 'ATG',
        '13' => 'AGT',
      }
      Bio::Fastahack.extract_sequences(%w(12 13), 'my.fa').should eq(expected)
    end
  end
  

  it "should work properly when a sequence is missing from the index" do
    test_wrapper %w(>12 ATG).join("\n") do
      lambda {Bio::Fastahack.extract_sequences(%w(12 13), 'my.fa')}.should raise_error
    end
  end
  
  it "should work properly when a sequence is missing from the index and out of order" do
    test_wrapper %w(>12 ATG >14 GATG).join("\n") do
      lambda {Bio::Fastahack.extract_sequences(%w(12 13 14), 'my.fa')}.should raise_error
    end
  end
end
