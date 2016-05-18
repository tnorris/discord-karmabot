require 'discordrb'
require 'pstore'
require 'yaml'
require_relative 'lib/rabblebot/rabble_bot_plugin'

# This is a simple discord bot that supports plugins
class RabbleBot
  attr_accessor :token, :app_id, :bot, :brain, :plugins, :config

  # expects you to set environment variables DISCORD_TOKEN and DISCORD_APP_ID
  # I used env vars because something something elastic beanstalk. (lol)
  def initialize
    load_config
    @token = ENV.fetch('DISCORD_TOKEN', @config[:DISCORD_TOKEN])
    @app_id = ENV.fetch('DISCORD_APP_ID', @config[:DISCORD_APP_ID])
    @bot = Discordrb::Bot.new token: @token, application_id: @app_id
    @bot.info "The first few characters of the discord token are: #{@token[0, 5]}"
    @bot.info "App_id is: #{@app_id}"
  end

  def load_plugins
    @bot.debug 'Loading plugins'
    RabbleBotPlugin.bot = @bot
    RabbleBotPlugin.require_plugins
    @plugins = RabbleBotPlugin.plugins.map do |plugin|
      @bot.info "Loading #{plugin}"
      config_name = plugin.to_s.split('::').last.downcase
      plugin.new @bot, @config[config_name]
    end
    @bot.debug 'Done loading plugins'
  end

  def load_config
    config_file_path = File.join(File.dirname(File.expand_path(__FILE__)), '/brains/config.yml')
    @config = YAML.load_file(config_file_path)
    # we're using STDERR.puts here because we don't have a logger yet
    STDERR.puts @config
  rescue StandardError => e
    STDERR.puts "Couldn't load #{config_file_path}. Error was:"
    STDERR.puts e
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
    # a discord bot
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
