require 'bio'

module Bio
  class Fastahack
    # Given a list of identifiers and a fastahack index, extract the corresponding
    # sequences from the fastahack index. Return a hash of sequence_id => sequence,
    # and then an array of those sequences not found.
    #
    # The index path is the same as that provided on the command line i.e. omit the
    # '.idx' suffix.
    def self.extract_sequences(sequence_identifier_list, index_path)
      log = Bio::Log::LoggerPlus['bio-fastahack']
      
      command = [
        "fastahack",
        '-c',
        index_path
      ]
      sequences_returned = {}
      unfound_sequences = []
      
      Bio::Command.call_command_open3(command) do |pin, pout, perr|
        pin.puts sequence_identifier_list.join("\n")
        pin.close
        
        # Read all the output lines, and error lines
        errors = perr.readlines
        unless errors.empty?
          raise "Error running fastahack: #{errors.join("\n")}"
        end
                
        # For each input sequence_id, assign it unless it has been reported as not found.
        # They come out in the same order as the IDs went in
        out_seqs = pout.readlines
        out_seq_index = 0
        sequence_identifier_list.each do |seq_id|
          if sequences_returned[seq_id].nil?
            sequences_returned[seq_id] = out_seqs[out_seq_index].chomp
            out_seq_index += 1
          else
            log.warn "Found duplicate sequence identifier #{seq_id}, taking the first sequence returned by fastahack."
          end
        end
      end
      
      return sequences_returned
    end
  end
end
