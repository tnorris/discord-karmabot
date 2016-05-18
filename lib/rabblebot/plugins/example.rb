class RabbleBot
  module RabbleBotPlugin
    # an example plugin
    class Example
      # creates a new plugin
      # always call super(bot) first, so your @bot and @brain objects are available
      # @param bot [Discordrb::Bot] a bot object that you can call
      def initialize(bot)
        super(bot)
        @bot.info 'Loading Example Plugin'
        add_query_handler
        @bot.info 'Example Plugin loaded!'
      end

      # adds a message handler that fires when someone sends
      # "/example <words>"
      def add_query_handler
        # for more matcher options, see Discordrb::EventContainer YARD
        # https://github.com/meew0/discordrb/blob/master/lib/discordrb/container.rb#L23
        @bot.message(start_with: '/example') do |e|
          @bot.info "Got a message from #{e.message.user.name}: #{e.message.content}"
        end
      end
    end
  end
end
