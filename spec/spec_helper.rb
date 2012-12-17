$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'bio-fastahack'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end


def test_wrapper(index_fasta)
  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do
      File.open('my.fa','w') do |f|
        f.puts index_fasta
        f.close
        
        `fastahack -i my.fa`
        
        yield
      end
    end
  end
end