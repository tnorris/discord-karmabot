require 'open-uri'
require 'json'

class RabbleBot
  module RabbleBotPlugin
    # a shout audio plugin
    class Shout < BasicPlugin
      def initialize(bot, config)
        super(bot, config)
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

      # TODO: refactor the switch into a config setting, so people can do arbitrary /shout thing -> sound.mp3, quip
      # by editing a yaml file
      # TODO: enable rubocop warning when yaml refactor happens
      # rubocop:disable Metrics/AbcSize
      def play_shout(e, shout) # rubocop:disable Metrics/MethodLength
        audio_file, quip = case shout
                           when 'cena'
                             [File.expand_path('./shout_includes/cena.mp3', __dir__),
                              '**HIS NAME IS JOHN CENA!!!**']
                           when 'explosions'
                             [File.expand_path('./shout_includes/torgue-explosions.mp3', __dir__),
                              '**EXPLOSIONS?!**']
                           when 'tinytinarun'
                             [File.expand_path('./shout_includes/tinytina-run.mp3', __dir__),
                              '**Run run run run, run run run run run...**']
                           when 'tffshout'
                             [File.expand_path('./shout_includes/tearsforfears-shout.mp3', __dir__),
                              '**Shout, Shout, Let it all out!**']
                           else
                             ['', "I don't know that one.."]
                           end
        e.respond quip
        unless audio_file.empty?
          voicebot = @bot.voice_connect(e.message.author.voice_channel)
          e.voice.play_file(audio_file)
          voicebot.destroy
        end
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
