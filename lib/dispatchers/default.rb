module Waves

  module Dispatchers

    #
    # The default dispatcher essentially checks the application's mapping to see
    # what to do with the request URL. It checks before and after filters (wrap
    # filters are just a combination of both) as well as path and url mappings.
    #
    # The default dispatcher also attempts to set the content type based on the
    # MIME type implied by any file extension used in the request URL using Mongrel's
    # MIME types YAML file.
    #
    # You can write your own dispatcher and use it in your application's configuration
    # file. By default, they use the default dispatcher, like this:
    #
    #   application do
    #     use Rack::ShowExceptions
    #     run Waves::Dispatchers::Default.new
    #   end
    #

    class Default < Base

      # All dispatchers using the Dispatchers::Base to provide thread-safety, logging, etc.
      # must provide a +safe+ method to handle creating a response from a request.
      # Takes a Waves::Request and returns a Waves::Reponse
      def safe( request  )

        response = request.response

        Waves::Application.instance.reload if Waves::Application.instance.debug?
        response.content_type = Waves::Application.instance.config.mime_types[ request.path ] || 'text/html'

        mapping = Waves.mapping[ request ]

        begin

          request.not_found unless mapping[ :action ]
          mapping[ :before ].each { | action | action.call( request ) }
          
          begin
            response.write( mapping[ :action ].first.call( request ) )
          ensure
            mapping[ :after ].each { | action | action.call( request ) }
          end
          
        rescue Exception => e

          raise e unless Waves.mapping.handle( e )

        ensure

          mapping[:always].each do | action |
            begin
              action.call( request ) 
            rescue Exception => e
              Waves::Logger.info e.to_s
            end
          end
          
        end

      end

    end

  end

end
