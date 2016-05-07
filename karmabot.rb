require 'discordrb'
require 'pstore'

# This is a simple karmabot, because we have it at work, but not at discord.
class KarmaBot
  attr_accessor :token, :app_id, :bot, :brain

  # expects you to set environment variables DISCORD_TOKEN and DISCORD_APP_ID
  # I used env vars because something something elastic beanstalk. (lol)
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
    add_help_handler
    add_query_handler

    STDERR.puts "My oauth authorization URL is: #{@bot.invite_url}"
  end

  # connect to discord and do stuff
  def run
    @bot.run
  end

  # figures out all the things to increment
  # @param [String] utterance message from user
  # @return [Array<String>] things that should be incremented
  def scan_increment(utterance)
    utterance.downcase.scan(/(\S+)\+\+/).flatten
  end

  # figures out all the things to decrement
  # @param [String] utterance message from user
  # @return [Array<String>] things that should be decremented
  def scan_decrement(utterance)
    utterance.downcase.scan(/(\S+)--/).flatten
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

  # Figures out what the karma for thing should be
  # @return [Integer] thing's karma
  def find_karma(thing)
    @brain.transaction do
      @brain[thing.downcase] || 0
    end
  end

  # Gets the karma scores for every word in a message
  # @param [String] message the message from the bot's event handler
  # @return [String] a markdown formatted mapping of things -> karma
  def karma_query(message)
    # tokenize the message into an array
    things_array = message.split ' '

    # ignore the /karma bit
    things_array = things_array[1, things_array.size]

    things_array.map! do |t|
      "#{t} has #{find_karma t} karma."
    end

    "```\n" + (things_array - [nil]) + "\n```"
  end

  # adds a message handler when someone sends "/karma help"
  def add_help_handler
    @bot.message(start_with: '/karma help') do |e|
      e.respond '/karma THING - tells you how much karma THING has.'
      e.respond "THING++ (anywhere in a message) increment THING's karma"
      e.respond "THING-- (anywhere in a message) decrement THING's karma"
    end
  end

  # adds a message handler that fires when someone sends
  # "/karma <THING> [<THING> [<THING> [...]]]"
  def add_query_handler
    @bot.message(start_with: '/karma') do |e|
      karma_query(e.message.content).each do |m|
        e.respond m
      end unless 'help' == e.message.content.split(' ')[1]
    end
  end

  # adds a message handler that fires on "words thing++ words words thing2++"
  def add_increment_handler
    @bot.message(contains: '++') do |e|
      things_to_bump = scan_increment(e.message.content).map do |thing|
        "#{thing}'s karma increased to #{deal_karma(thing, 1)}"
      end

      things_to_bump.each { |m| e.respond m }
    end
  end

  # adds a message handler that fires on "words thing-- words words thing2--"
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
