require 'pp'

class RabbleBot
  module RabbleBotPlugin
    # an example plugin
    class Example
      attr_accessor :bot

      # creates a new plugin
      # @param bot [Discordrb::Bot] a bot object that you can call
      def initialize(bot)
        @bot = bot
        @bot.info 'Loading Example Plugin'
        add_query_handler
        @bot.info 'Example Plugin loaded!'
      end

      # adds a message handler that fires when someone sends
      # "/karma <THING> [<THING> [<THING> [...]]]"
      def add_query_handler
        @bot.message(start_with: '/example') do |e|
          @bot.info "Got a message from #{e.message.user.name}: #{e.message.content}"
        end
      end
    end
  end
end
