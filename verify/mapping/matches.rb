# require 'test_helper' because RubyMate needs help
require File.join(File.dirname(__FILE__), "..", "helpers")

specification "A developer can extract parameters from a request path or URL." do

  before do
    mapping.clear

    path '/param/{value}' do |value|
      "You asked for: #{value}."
    end

    url 'http://localhost:{port}/port', :match => { :port => '(\d+)' } do |port|
      port
    end

  end

  specify 'Extract a parameter via a regexp match of the path.' do
    get('/param/elephant').body.should == 'You asked for: elephant.'
  end

  specify 'Extract a parameter via a regexp match of the URL.' do
    get('http://localhost:3000/port').body.should == '3000'
  end

end
