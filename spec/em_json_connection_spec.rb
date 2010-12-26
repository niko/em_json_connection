require File.join( File.expand_path(File.dirname(__FILE__)), '../lib/em_json_connection' )

class ConnectionSuperClass
  def send_data(d); end
end

class TestConnection < ConnectionSuperClass
  include EM::JsonConnection::Base
end

class TestServer
  include EM::JsonConnection::Server
end
class TestClient
  include EM::JsonConnection::Client
end

describe EM::JsonConnection::Base do
  before(:each) do
    @connection = TestConnection.new(File.join( File.expand_path(File.dirname(__FILE__)), 'test_socket' ))
  end
  describe "#post_init" do
    it "should initialize the parser" do
      @connection.should_receive(:init_parser).once
      @connection.post_init
    end
    it "should set the encoder" do
      Yajl::Encoder.should_receive(:new).and_return(:some_encoder)
      @connection.post_init
      @connection.instance_variable_get("@encoder").should == :some_encoder
    end
  end
  describe "#init_parser" do
    before(:each) do
      @parser_mock = mock(:some_parser, :on_parse_complete= => true)
      Yajl::Parser.stub!(:new => @parser_mock)
    end
    it "should set the parser" do
      Yajl::Parser.should_receive(:new).with(:symbolize_keys => true).and_return(@parser_mock)
      @connection.init_parser
      @connection.instance_variable_get("@parser").should == @parser_mock
    end
    it "should set the callback-method for the parser" do
      @parser_mock.should_receive(:on_parse_complete=).with(@connection.method(:json_parsed))
      @connection.init_parser
    end
  end
  describe "#receive_data" do
    before(:each) do
      @parser_mock = mock(:some_parser, :on_parse_complete= => true)
      Yajl::Parser.stub!(:new => @parser_mock)
      @connection.init_parser
    end
    it "should feed the data to the parser" do
      @parser_mock.should_receive(:<<).with('foo')
      @connection.receive_data('foo')
    end
    describe "when a parsing error occurs" do
      before(:each) do
        @parser_mock.stub!(:<<).and_raise(Yajl::ParseError.new('some error'))
      end
      it "should rescue the error" do
        lambda{ @connection.receive_data('foo') }.should_not raise_error
      end
      it "should re-initialize the parser" do
        @connection.should_receive(:init_parser)
        @connection.receive_data('foo')
      end
    end
  end
  describe "#send_data" do
    before(:each) do
      @connection.post_init
    end
    it "should call super with the data encoded" do
      @connection.instance_variable_get('@encoder').should_receive(:encode).with({:a => 1})
      @connection.send_data({:a => 1})
    end
  end
  describe "when connected" do
    before(:each) do
      @connection.post_init
    end
    describe "#connected?" do
      it "should be true" do
        @connection.connected?.should be_true
      end
    end
  end
  describe "when NOT connected" do
    before(:each) do
      @connection.post_init
      @connection.unbind
    end
    describe "#connected?" do
      it "should be false" do
        @connection.connected?.should be_false
      end
    end
  end
end

describe EM::JsonConnection::Server do
  describe ".start_at" do
    it "should start an EM server" do
      EM.should_receive(:start_server).with('foo', nil, TestServer)
      TestServer.start_at 'foo'
    end
  end
end


describe EM::JsonConnection::Client do
  describe ".connect_to" do
    it "should connect to an EM server" do
      EM.should_receive(:connect).with('foo', nil, TestClient)
      TestClient.connect_to 'foo'
    end
  end
end
