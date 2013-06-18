require_relative '../../../lib/server'
require_relative '../../../lib/sandbox'

class Sb_Server_Organizer

  def source()
    Sandbox.new
  end

  def destination
    Server.new
  end

end

