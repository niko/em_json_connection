require 'eventmachine'
require 'yajl'

module EM::JsonConnection; end

module EM::JsonConnection::Base
  def post_init
    init_parser
    @encoder = Yajl::Encoder.new
  end
  
  def init_parser
    @parser = Yajl::Parser.new(:symbolize_keys => true)
    @parser.on_parse_complete = method(:json_parsed)
  end
  
  def receive_data(data)
    # p data
    @parser << data
  rescue Yajl::ParseError => error
    puts "Yajl::ParseError: #{error}"
    init_parser
  end
  
  def json_parsed(hash)
    puts 'to be implemented in the subclass'
  end
  
  def send_data(data)
    super @encoder.encode(data)
  # rescue JSON::GeneratorError => error
  #   puts "JSON::GeneratorError: #{error}"
  #   @encoder = Yajl::Encoder.new
  end
end

module EM::JsonConnection::Server
  include EM::JsonConnection::Base
  
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def start_at(host, port=nil)
      EM.start_server(host, port, self)
    end
  end
end

module EM::JsonConnection::Client
  include EM::JsonConnection::Base
  
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def connect_to(host, port=nil)
      EM.connect(host, port, self)
    end
  end
end
