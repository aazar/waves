# See the README for an overview.
module Waves
  
  # this is temporay until the applications "array" becomes a hash
  class Applications < Array
    def []( name ) ; self.find { |app| app.name == name.to_s.camel_case } ; end
  end
  
  class << self

    # Access the principal Waves application.
    def applications ; @applications ||= Applications.new ; end

    # This is being deprecated. Do not write new code against this.
    def application ; applications.last ; end
    
    def main ; applications.first ; end
    
    # Register a module as a Waves application.
    def << ( app )
      applications << app if Module === app
    end

    def instance ; Waves::Runtime.instance ; end

    def method_missing(name,*args,&block) ; instance.send(name,*args,&block) ; end

  end

  # An application in Waves is anything that provides access to the Waves
  # runtime and the registered Waves applications. This includes both
  # Waves::Server and Waves::Console. Waves::Runtime is *not* the actual
  # application module(s) registered as Waves applications. To access the
  # main Waves application, you can use +Waves+.+application+.
  class Runtime

    class << self; attr_accessor :instance; end

    # Accessor for options passed to the application.
    attr_reader :options

    # Create a new Waves application instance.
    def initialize( options={} )
      @options = options
      Dir.chdir options[:directory] if options[:directory]
      Runtime.instance = self
      Kernel.load( :lib / 'application.rb' ) if Waves.main.nil?
    end

    def synchronize( &block )
      ( @mutex ||= Mutex.new ).synchronize( &block )
    end

    # The 'mode' of the application determines which configuration it will run under.
    def mode
      @mode ||= @options[:mode]||:development
    end
    
    # Debug is true if debug is set to true in the current configuration.
    def debug? ; config.debug ; end

    # Access the current configuration. *Example:* +Waves::Server.config+
    def config
      Waves.main::Configurations[ mode ]
    end

    # Access the mappings for the application.
    def mapping ; Waves.main::Configurations[ :mapping ] ; end

    # Reload the modules specified in the current configuration.
    def reload ; config.reloadable.each { |mod| mod.reload } ; end

    # Returns the cache set for the current configuration
    def cache ; config.cache ; end
  end

end
