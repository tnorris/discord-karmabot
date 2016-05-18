require 'discordrb'
require 'pstore'
require_relative 'lib/rabblebot/rabble_bot_plugin'

# This is a simple discord bot that supports plugins
class RabbleBot
  attr_accessor :token, :app_id, :bot, :brain, :plugins

  # expects you to set environment variables DISCORD_TOKEN and DISCORD_APP_ID
  # I used env vars because something something elastic beanstalk. (lol)
  def initialize
    @token = ENV.fetch('DISCORD_TOKEN')
    @app_id = ENV.fetch('DISCORD_APP_ID')
    @bot = Discordrb::Bot.new token: @token, application_id: @app_id
  end

  def load_plugins
    @bot.debug 'Loading plugins'
    RabbleBotPlugin.bot = @bot
    RabbleBotPlugin.require_plugins
    @plugins = RabbleBotPlugin.plugins.map { |plugin| plugin.new @bot }
    @bot.debug 'Done loading plugins'
  end

  # set up the event handlers, spout out an oAuth url
  def bootstrap
    STDERR.puts "My oauth authorization URL is: #{@bot.invite_url}"
    load_plugins
  end

  # connect to discord and do stuff
  def run
    @bot.run
  end
end

# Monkey Patch .info into Discordrb
unless Discordrb::Bot.respond_to? :info
  module Discordrb
    class Bot
      def info(message)
        LOGGER.info(message)
      end
    end
  end
end

k = RabbleBot.new
k.bootstrap
k.run
