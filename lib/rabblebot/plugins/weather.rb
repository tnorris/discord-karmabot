require 'open-uri'
require 'json'
require 'yaml'

# Name      : Weather Plugin for RabbleBot
# Created   : 5/2016
# Author(s) : quizy101 & tnorris
# Purpose   : This will allow '/weather kbos' to get weather at logan airport.
class RabbleBot
  attr_accessor :google_api, :forecastio_api, :weather_config
  module RabbleBotPlugin
    # BEGIN PLUGIN
    class Weather < BasicPlugin
      # Initializes the plugin with the bot super
      # @param [bot] bot from rabblebot.rb
      # @param [config] config from rabblebot.rb
      # @return [void] nothing to see
      def initialize(bot, config)
        puts 'Loading Weather Plugin'
        super(bot, config)
        begin
          @google_api = ENV.fetch('GOOGLE_API_KEY', @config[:GOOGLE_API_KEY])
          @forecastio_api = ENV.fetch('FORECAST_IO_KEY', @config[:FORECAST_IO_KEY])
          load_weather_config
        rescue StandardError => msg
          load_config_error(msg)
        end
        add_weather_handler
        puts 'Weather Plugin loaded!'
      end

      # Loads the weather_config.yml for the plugin to use
      # @raise File::StandardError
      def load_weather_config
        config_file_path = File.join(File.dirname(File.expand_path(__FILE__)), '/weather_includes/weather_config.yml')
        @weather_config = YAML.load_file(config_file_path)
      rescue StandardError => e
        # we're using STDERR.puts here because we don't have a logger yet
        STDERR.puts "Couldn't load #{config_file_path}. Error was:"
        STDERR.puts e
        raise e
      end

      # Outputs a readable error message to the console if the config fails to load
      # @param [string] msg with error message
      # @return [void] nothing to see
      def load_config_error(msg)
        puts <<-EOT
          ********************* ERROR ************************
          Weather Plugin Config Error:
          One of the API keys is missing or incorrect.
          Check your /brains/config.yml file or ENV variables.
          Exception: #{msg}
          ********************* ERROR ************************
        EOT
      end

      # Sends a message to the channel with the plugin help text
      # @param [event] e message event object
      # @return [void] nothing to see
      def weather_help(e)
        e.respond <<-EOT
          /weather 'any location' - type whatever you like to find the weather, if google maps can find it, the weather plugin will too.
        EOT
      end

      # Generates the latitude and longitude based on the location to send to build_response
      # @param [event] e event object used to track the channel
      # @param [string] message location that was typed into the channel
      # @return [void] nothing to see
      def weather_query(e, message)
        lat, lng, location = get_location_from_gmaps(message)
        forecast_io_json = get_forecast(lat, lng)
        e.respond build_response(forecast_io_json, location)
      end

      # Creates the response with weather info based on forecast_io json data
      # @param [string] forecast_io_json json array with weather info
      # @param [string] location location name that was returned from gmaps
      # @return [string] returns the string with all the weather and location information
      # i can't shrink the assign/branch/condition down any further without making this method harder to read
      def build_response(forecast_io_json, location) # rubocop:disable Metrics/AbcSize
        emoji = ":#{@weather_config['emojis'].fetch(forecast_io_json['currently']['icon'], '(no emoji :( )')}:"
        <<-EOT.gsub(/^\s+/, '')
          *Current Weather for #{location}:*
          Status: #{forecast_io_json['currently']['summary']} #{emoji}
          Temperature: #{forecast_io_json['currently']['temperature']} F
          Humidity: #{forecast_io_json['currently']['humidity'].to_f * 100}%
          Wind Speed: #{forecast_io_json['currently']['windSpeed']} mph
          Cloud Cover: #{forecast_io_json['currently']['cloudCover'].to_f * 100}%
        EOT
      end

      # Takes a latitude and longitude and grabs a response from forecast.io
      # @param [string] lat latitude
      # @param [string] lng longitude
      # @return [string] json response from forecast.io
      def get_forecast(lat, lng)
        forecast_url = "https://api.forecast.io/forecast/#{@forecastio_api}/#{lat},#{lng}"
        forecast_io_response = open(forecast_url).read
        JSON.parse(forecast_io_response)
      end

      # Using search term google geocode tries to find the latitude, longtitude, and name of a location
      # @param [string] message search term used
      # @return [string[]] string array with latitude, longitude, and location
      # ditto about AbcSize here. If I reduce 'complexity' I also reduce clarity.
      def get_location_from_gmaps(message) # rubocop:disable Metrics/AbcSize
        gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{message.join ' '}&key=#{@google_api}"
        gmaps_json_response = open(gmaps_url).read
        gmaps_json = JSON.parse(gmaps_json_response)
        location = gmaps_json['results'][0]['formatted_address']
        lat = gmaps_json['results'][0]['geometry']['location']['lat']
        lng = gmaps_json['results'][0]['geometry']['location']['lng']
        [lat, lng, location]
      end

      # Listen to messages to determine if the weather plugin has been called,
      # if yes then it will decide to give you help or to process the query.
      # @return [void] nothing to see
      def add_weather_handler
        @bot.message(start_with: '/weather') do |e|
          query_msg = e.message.content.split(' ')
          if 'help' == query_msg[1]
            weather_help(e)
          else
            weather_query(e, query_msg[1])
          end
        end
      end
    end
  end
end
