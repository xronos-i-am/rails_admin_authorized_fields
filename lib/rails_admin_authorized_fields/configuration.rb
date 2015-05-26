module RailsAdminAuthorizedFields
  class << self
    def configuration
      @configuration ||= Configuration.new
    end
    def config
      configuration
    end
    def configure
      yield configuration
    end
  end

  class Configuration
    attr_accessor :default_rule
  end
end
