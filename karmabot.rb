require 'discordrb'
require 'pstore'

# This is a simple karmabot, because we have it at work, but not at discord.
class KarmaBot
  attr_accessor :token, :app_id, :bot, :brain

  # expects you to set environment variables DISCORD_TOKEN and DISCORD_APP_ID
  # I used env vars because something something elastic beanstalk.
  def initialize
    @token = ENV.fetch('DISCORD_TOKEN')
    @app_id = ENV.fetch('DISCORD_APP_ID')
    @bot = Discordrb::Bot.new token: @token, application_id: @app_id
  end

  # set up the event handlers, spout out an oAuth url
  def bootstrap
    @brain = PStore.new('karmabot.pstore')

    add_increment_handler
    add_decrement_handler

    STDERR.puts "My oauth authorization URL is: #{@bot.invite_url}"
  end

  def run
    @bot.run
  end

  def scan_increment(utterance)
    utterance.scan(/(\S+)\+\+/).flatten
  end

  def scan_decrement(utterance)
    utterance.scan(/(\S+)--/).flatten
  end

  # @param thing [String] the thing you want to change the karma of
  # @param modifier [Integer] the amount change you want to apply
  # @return [Integer] thing's new karma value
  # @raise PStore::Error
  def deal_karma(thing, modifier)
    @brain.transaction do
      @brain[thing] = if @brain[thing].nil?
                        modifier
                      else
                        @brain[thing] + modifier
                      end

      @brain[thing]
    end
  end

  def add_increment_handler
    @bot.message(contains: '++') do |e|
      things_to_bump = scan_increment(e.message.content).map do |thing|
        "#{thing}'s karma increased to #{deal_karma(thing, 1)}"
      end

      things_to_bump.each { |m| e.respond m }
    end
  end

  def add_decrement_handler
    @bot.message(contains: '--') do |e|
      things_to_dock = scan_decrement(e.message.content).map do |thing|
        "#{thing}'s karma decreased to #{deal_karma(thing, -1)}"
      end

      things_to_dock.each { |m| e.respond m }
    end
  end
end

k = KarmaBot.new
k.bootstrap
k.run
