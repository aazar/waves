module Waves

  module Mapping
    
    class Action
      
      def initialize( options )
        @name = name = options[:name] ; @pattern = pattern = Pattern.new( options )
        @constraints = Constraints.new( options ) ; @descriptors = Descriptors.new( options )
        @block = block = options[:block]
        if rname = options[ :resource ]
          @resource = resource = Waves.main[:resources][ rname ]
        else
          resource = Waves.main[:resources][ :default ]
          @resource = Waves::Resources::Proxy
        end
        if name
          resource.define_action( name, &block ) if block
          resource::Paths.define_path( name, options[ :path ] )
        end
      end
      
      def bind( request )
        ( @constraints.satisfy?( request ) and 
          ( params = @pattern.match( request ) ) and Binding.new( self, params ) )
      end
      
      def call( request )
        if @name
          @resource.new( request ).send( @name )
        elsif @block
          @resource.new( request ).instance_eval( &@block )
        end
      end

      def threaded?
        @descriptors.threaded?
      end
      
    end
    
    class Binding
      
      def initialize( action, params )
        @action = action ; @params = params
      end
      
      def call( request )
        request.params.merge!( @params )
        @action.call( request )
      end
    
      def method_missing(name,*args,&block)
        @action.respond_to?( name ) ? @action.send( name, *args, &block ) : super
      end
    end
    
  end

end