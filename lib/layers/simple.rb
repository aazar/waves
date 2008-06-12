module Waves
  
  # Waves uses Layers to provide discrete, stackable, interchangeable bundles of functionality.
  # 
  # Developers can make use of Layers by including them directly in a Waves application:
  # 
  #   module MyApp
  #     include SomeLayer
  #   end
  module Layers
    
    # Creates the Configurations namespace and establishes the standard autoload-or-autocreate
    # rules.
    module Simple
      def self.included( app )

        def app.config ; Waves.config ; end
        def app.configurations ; self::Configurations ; end
        
        app.instance_eval do

          include AutoCode
          
          auto_create_module( :Configurations ) do
            include AutoCode
            auto_create_class true, Waves::Configurations::Default
            auto_load :Mapping, :directories => [:configurations]
            auto_load true, :directories => [:configurations]
            auto_eval :Mapping do
              extend Waves::Mapping
            end
          end

        end
      end
    end
  end
end
      