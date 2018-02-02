class FerroSequence
  
  def initialize(label = nil)
    @label   = label
    @next_id = 0
  end

  def next
    @next_id += 1
    "#{@label}#{@next_id}"
  end
end