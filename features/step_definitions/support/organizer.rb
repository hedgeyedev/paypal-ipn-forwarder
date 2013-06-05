require_relative '../../../lib/server'
require_relative '../../../lib/computer'

class Organizer

  # Set up this object with names that can be used to look up objects needed to run this test
  # @param [String] source_id the unique name for the source object
  # @param [String] destination_id the unique name for the destination object
  def initialize(source_id, destination_id)

  end

  def source(ipn=nil)
    Server.new(ipn)
  end

  def destination
    Computer.new
  end

end
