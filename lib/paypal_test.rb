PROCESS_FILE_NAME = '.process_id'

def initialize
  @router = router.new
  @poll = @poll(@router)
end


def start
  process_id = fork{exec "ruby lib/router.rb"}
  write_process_id(process_id)
  puts 'Paypal testing has started'
end

def stop
  @poll.test_mode_off
  process_id = read_process_id
  Process.kill("HUP", process_id)
  Process.wait
  puts 'Paypal testing has been terminated'
end

def read_process_id
  File.read(PROCESS_FILE_NAME)
end

def write_process_id(process_id)
  File.write(PROCESS_FILE_NAME, process_id, nil, nil)
end
