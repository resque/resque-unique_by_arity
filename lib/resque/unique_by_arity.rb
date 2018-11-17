# Just in case some code still does require 'resque/unique_by_arity'
require 'resque-unique_by_arity'

module Resque
  module UniqueByArity
    PLUGIN_TAG = (ColorizedString['[R-UBA] '].green).freeze

    def log(message, config_proxy = nil)
      config_proxy ||= configuration
      config_proxy.logger&.send(config_proxy.log_level, message) if config_proxy.logger
    end
    module_function(:log)

    def debug(message, config_proxy = nil)
      config_proxy ||= configuration
      config_proxy.logger&.debug("#{Resque::UniqueByArity::PLUGIN_TAG}#{message}") if config_proxy.debug_mode
    end
    module_function(:debug)

    # For config with a block
    def configure
      yield(@configuration)
    end
    module_function(:configure)

    #### CONFIG ####
    # Access globally configured settings:
    #   >> Resque::UniqueByArity.configuration.logger
    #   => the Logger instance
    class << self
      attr_accessor :configuration
    end
    self.configuration = GlobalConfiguration.instance # setup defaults
  end
end
