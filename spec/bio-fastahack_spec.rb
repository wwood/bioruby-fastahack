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
  
  it "should handle a 1000 input sequences" do
    input_fasta = []
    3000.times do |i|
      input_fasta.push [
        ">seq#{i}",
        %w(A T G C)[i % 4]*2
      ]
    end
    input_fasta = input_fasta.flatten.join("\n")
    
    test_wrapper input_fasta do
      extracts = Bio::Fastahack.extract_sequences((1..1000).to_a.collect{|s| "seq#{s}"}, 'my.fa')
      extracts.length.should eq(1000)
      extracts['seq1'].should eq('TT')
      extracts['seq2'].should eq('GG')
      (1..1000).each do |i|
        extracts["seq#{i}"].length.should eq(2)
      end
    end
  end
  
  it "should handle a 1000 input sequences and a big size database" do
    input_fasta = []
    30000.times do |i|
      input_fasta.push [
        ">seq#{i}",
        %w(A T G C)[i % 4]*2000
      ]
    end
    input_fasta = input_fasta.flatten.join("\n")
    
    test_wrapper input_fasta do
      $stderr.puts "Finished index file, now extracting the sequences. If this takes too long then we've failed. This fails when using popen3."
      
      extracts = Bio::Fastahack.extract_sequences((1..1000).to_a.collect{|s| "seq#{s}"}, 'my.fa')
      extracts.length.should eq(1000)
      extracts['seq1'].should eq('T'*2000)
      extracts['seq2'].should eq('G'*2000)
      (1..1000).each do |i|
        extracts["seq#{i}"].length.should eq(2000)
      end
    end
  end
  
end
