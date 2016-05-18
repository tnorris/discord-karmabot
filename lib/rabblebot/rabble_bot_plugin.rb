require 'logger'
require_relative 'basic_plugin'

class RabbleBot
  # a plugin helper that loads, catalogs, and blacklists plugins
  module RabbleBotPlugin
    class << self
      attr_accessor :bot, :brain

      # loads all of the rabblebot plugins
      # TODO: stop crashing plugins from taking down the entire bot
      def require_plugins
        Dir[File.dirname(__FILE__) + '/plugins/*.rb'].each do |file|
          plugin_file_name = file.split('/').last.gsub('.rb', '')
          require_relative "plugins/#{plugin_file_name}"
        end
      end

      # allows the user to set an environment variable to disable plugins
      # example: DIABLED_PLUGINS=crashful,pingflood,eval
      def disabled_plugins
        ENV.fetch('DISABLED_PLUGINS', 'Example').split(',').map(&:to_sym)
      end

      def plugins
        plugin_constants = RabbleBot::RabbleBotPlugin.constants - disabled_plugins
        plugin_constants.map { |plugin| RabbleBot::RabbleBotPlugin.const_get plugin }
      end
    end
  end
end
