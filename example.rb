$LOAD_PATH << File.join(File.expand_path(File.dirname(__FILE__)), 'lib')

require 'eventmachine'
require 'em_json_connection'

module Server
  include EM::JsonConnection::Server
  
  def json_parsed(hash)
    puts "Client sent: #{hash}"
    
    send_data hash
  end
end

module Client
  include EM::JsonConnection::Client
  
  def json_parsed(hash)
    puts "Server responded: #{hash}"
  end
end

EM.fork_reactor do
  Server.start_at '/tmp/foo'
  
  EM.add_timer(5) do
    puts 'stopping server'
    EM.stop
  end
end

sleep 0.1 # wait, so the server is up

EM.fork_reactor do
  c = Client.connect_to '/tmp/foo'
  
  EM.add_periodic_timer 1 do
    c.send_data({:pid => Process.pid})
  end
  
  EM.add_timer(5) do
    puts 'stopping client'
    EM.stop
  end
end

Process.waitall
