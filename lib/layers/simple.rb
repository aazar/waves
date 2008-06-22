module Waves
  module Layers
    module Simple
      def self.included( app )

        def app.config ; Waves.config ; end
        def app.configurations ; self::Configurations ; end
        def app.paths ; configurations::Mapping.named; end
        def app.resources ; self::Resources ; end
        
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
          
          auto_create_module( :Resources ) do
            include AutoCode
            auto_create_class true, Waves::Resources::Base
          end

        end
      end
    end
  end
end
      