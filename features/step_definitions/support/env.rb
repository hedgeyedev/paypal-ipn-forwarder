#app_file = File.join(File.dirname(__FILE__), *%w[.. .. app.rb])
#require app_file
# Force the application name because polyglot breaks the auto-detection logic.
#Sinatra::Application.app_file = app_file

require 'rspec/expectations'
#require 'rack/test'

class MyWorld
  #include Rack::Test::Methods

  # Scott: keep around for reference; we're going to do this in Capybara
  #Webrat::Methods.delegate_to_session :response_code, :response_body

  def app
    #Sinatra::Application
  end
end

World{MyWorld.new}
