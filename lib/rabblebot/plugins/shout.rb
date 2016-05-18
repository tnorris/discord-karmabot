require 'open-uri'
require 'json'

class RabbleBot
  module RabbleBotPlugin
    # a shout audio plugin
    class Shout < BasicPlugin
      def initialize(bot)
        super(bot)
        @bot.info 'Loading Shout Plugin'
        add_shout_handler
        @bot.info 'Shout Plugin loaded!'
      end
      
      def shout_help(e)
        commands = <<-EOT.gsub(/^\s+/, '')
          **List of shout commands:**
          /shout cena - HIS NAME IS JOHN CENA!!!
          /shout explosions - Mr. Torgue loves explosions
          /shout tinytinarun - Tiny Tina loves to run.
          /shout tffshout - Shout, Shout, Let it all out.
        EOT
        e.respond "\n#{commands}"
      end

      def play_shout(e, shout)
        voicebot = @bot.voice_connect(e.message.author.voice_channel)
        case shout
          when 'cena'
            audio_file = File.expand_path("./shout_includes/cena.mp3", __dir__)
            e.respond "**HIS NAME IS JOHN CENA!!!**"
            e.voice.play_file(audio_file)
          when 'explosions'
            audio_file = File.expand_path("./shout_includes/torgue-explosions.mp3", __dir__)
            e.respond "**EXPLOSIONS?!**"
            e.voice.play_file(audio_file)
          when 'tinytinarun'
            audio_file = File.expand_path("./shout_includes/tinytina-run.mp3", __dir__)
            e.respond "**Run run run run, run run run run run...**"
            e.voice.play_file(audio_file)
          when 'tffshout'
            audio_file = File.expand_path("./shout_includes/tearsforfears-shout.mp3", __dir__)
            e.respond "**Shout, Shout, Let it all out!**"
            e.voice.play_file(audio_file)
        end
        voicebot.destroy
      end

      def add_shout_handler
        @bot.message(start_with: '/shout') do |e|
          query_msg = e.message.content.split(' ')
          
          if 'help' == query_msg[1]
            shout_help(e)
          else
            play_shout(e, query_msg[1])
          end
        end
      end
    end
  end
end
