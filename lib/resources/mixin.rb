module Waves
  
  module Resources
    
    module Mixin
      
      attr_reader :request

      include ResponseMixin
      
      def self.included( target )
        parent = target.superclass
        base = parent.respond_to?( :paths ) ? parent.paths : Waves::Mapping::Paths
        target.module_eval do
          const_set( :Paths, Class.new( base ) )
          def self.paths ; @object ||= self::Paths.new( self ) ; end
          def self.singular ; basename.downcase ; end
          def self.plural ; basename.downcase.plural ; end
          
          def self.define_action(name, &block)
            define_method( name, &block )
          end
        end
      end
      
      def initialize(request); @request = request ; end
      def singular ; self.class.singular ; end
      def plural ; self.class.plural ; end
      def redirect( path ) ; request.redirect( path ) ; end
      
      # Matthew thinks this method is getting obscured by the Simple layer
      def paths ; self.class.paths ; end
    end
      
    # :)
    const_set( :Base, Class.new ).module_eval { include Mixin }

  end


end
