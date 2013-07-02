require_relative '../../../lib/server'
require_relative '../../../lib/development_computer'
require_relative '../../../lib/sandbox'
require_relative '../../../lib/mail_sender'

class Organizer

  attr_accessor :server, :sandbox, :computer, :mail_sender

  # Set up this object with names that can be used to look up objects needed to run this test
  # @param [String] source_id the unique name for the source object
  # @param [String] destination_id the unique name for the destination object

  TEST_MODE_ON = true
  def initialize
    @server = Server.new(TEST_MODE_ON)
    @sandbox = Sandbox.new
    @computer = DevelopmentComputer.new
    @mail_sender = MailSender.new
  end
end
