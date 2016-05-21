require 'open-uri'
require 'json'

class RabbleBot
  # shout plugin
  module RabbleBotPlugin
    attr_accessor :shout_config, :playing
    # a shout audio plugin
    class Shout < BasicPlugin
      def initialize(bot, config)
        super(bot, config)
        load_config
        @bot.info 'Loading Shout Plugin'
        add_shout_handler
        @playing = false
        @bot.info 'Shout Plugin loaded!'
      end

      def load_config
        config_file_path = File.join(File.dirname(File.expand_path(__FILE__)), '/shout_includes/shout_config.yml')
        @shout_config = YAML.load_file(config_file_path)
      rescue StandardError => e
        # we're using STDERR.puts here because we don't have a logger yet
        STDERR.puts "Couldn't load #{config_file_path}. Error was:"
        STDERR.puts e
        raise e
      end

      def shout_help(e)
        help_text = ''
        @shout_config['shouts'].each do |k, v|
          help_text += "/shout #{k} - #{v['help']}\n"
        end
        commands = <<-EOT.gsub(/^\s+/, '')
          **List of shout commands:**
          #{help_text}
        EOT
        e.respond "\n#{commands}"
      end

      # TODO: enable rubocop warning when yaml refactor happens
      def play_shout(e, audio_file, quip)
        unless audio_file.empty?
          unless @playing
            begin
              e.respond "**#{quip}**"
              @playing = true
              voicebot = @bot.voice_connect(e.message.author.voice_channel)
              e.voice.play_file(audio_file)
              voicebot.destroy
            ensure
              @playing = false
            end
        end
      end

      def add_shout_handler
        @bot.message(start_with: '/shout') do |e|
          query_msg = e.message.content.split(' ')
          shout = query_msg[1]
          if 'help' == shout
            shout_help(e)
          else
            c = @shout_config['shouts'][shout]
            play_shout(e, File.expand_path(c['file'], __dir__), c['quip'])
          end
        end
      end
    end
  end
end
