module Waves

  module Dispatchers

    class NotFoundError < Exception ; end

    class Redirect < Exception
      attr_reader :path, :status
      def initialize( path, status = '302' )
        @path = path
        @status = status
      end
    end

    # Waves::Dispatchers::Base provides the basic request processing structure.
    # All other Waves dispatchers should inherit from it.  It creates a Waves request, 
    # determines whether to enclose the request processing in a mutex, benchmarks it, 
    # logs it, and handles common exceptions and redirects. Derived classes need only 
    # process the request within the +safe+ method, which must take a Waves::Request and return a Waves::Response.

    class Base

      # As with any Rack application, a Waves dispatcher must provide a call method
      # that takes an +env+ parameter.
      def call( env )
        if Waves.config.synchronize?
          Waves::Application.instance.synchronize { _call( env ) }
        else
          _call( env )
        end
      end

      # Called by event driven servers like thin and ebb. Returns true if
      # the server should run the request in a separate thread.  This is usually
      # set using Configurations::Mapping#threaded
      def deferred?( env )
        Waves::Application.instance.mapping.threaded?( env )
      end
      
      private
      
      def _call( env )
        request = Waves::Request.new( env )
        response = request.response
        t = Benchmark.realtime do
          begin
            safe( request )
          rescue Dispatchers::Redirect => redirect
            response.status = redirect.status
            response.location = redirect.path
          end
        end
        Waves::Logger.info "#{request.method}: #{request.url} handled in #{(t*1000).round} ms."
        response.finish
      end

    end

  end

end
