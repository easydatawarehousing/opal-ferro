module Ferro
  # A helper class to generate unique labels.
  # These labels can be used to ensure
  # unique instance variable names.
  class Sequence

    # Create a new sequence.
    #
    # @param [String] prefix a prefix for generated labels
    def initialize(prefix = nil)
      @prefix  = prefix
      @next_id = 0
    end

    # Get the next label.
    #
    # @return [String] the unique label
    def next
      @next_id += 1
      "#{@prefix}#{@next_id}"
    end
  end
end