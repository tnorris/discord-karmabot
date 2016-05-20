require 'open-uri'
require 'json'

# a weather plugin
class RabbleBot
  attr_accessor :google_api, :forecastio_api
  module RabbleBotPlugin
    # so you can do /weather kbos
    class Weather < BasicPlugin
      # methodlength probably shouldn't be enforced in the initializer..
      def initialize(bot, config) # rubocop:disable Metrics/MethodLength
        super(bot, config)
        begin
          @google_api = ENV.fetch('GOOGLE_API_KEY', @config[:GOOGLE_API_KEY])
          @forecastio_api = ENV.fetch('FORECAST_IO_KEY', @config[:FORECAST_IO_KEY])
        rescue StandardError => msg
          puts <<-EOT
          ********************* ERROR ************************
          Weather Plugin Config Error:
          One of the API keys is missing or incorrect.
          Check your /brains/config.yml file or ENV variables.
          Exception: #{msg}
          ********************* ERROR ************************
          EOT
        end
        add_weather_handler
      end

      def weather_help(e)
        e.respond '/weather ZIP - tells you what the weather of ZIP is.'
      end

      def weather_query(e, message)
        lat, lng, location = get_location_from_gmaps(message)

        forecast_io_json = get_forecast(lat, lng)

        e.respond build_response(forecast_io_json, location)
      end

      # i can't shrink the assign/branch/condition down any further without making this method harder to read
      def build_response(forecast_io_json, location) # rubocop:disable Metrics/AbcSize
        emoji = ":#{@config['emojis'].fetch(forecast_io_json['currently']['icon'], '(no emoji :( )')}:"
        <<-EOT.gsub(/^\s+/, '')
          *Current Weather for #{location}:*
          Status: #{forecast_io_json['currently']['summary']} #{emoji}
          Temperature: #{forecast_io_json['currently']['temperature']} F
          Humidity: #{forecast_io_json['currently']['humidity'].to_f * 100}%
          Wind Speed: #{forecast_io_json['currently']['windSpeed']} mph
          Cloud Cover: #{forecast_io_json['currently']['cloudCover'].to_f * 100}%
        EOT
      end

      def get_forecast(lat, lng)
        forecast_url = "https://api.forecast.io/forecast/#{@forecastio_api}/#{lat},#{lng}"
        forecast_io_response = open(forecast_url).read
        JSON.parse(forecast_io_response)
      end

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

      def add_weather_handler
        @bot.message(start_with: '/weather') do |e|
          query_msg = e.message.content.split(' ')
          query_msg = query_msg[1, query_msg.size]
          if 'help' == query_msg
            weather_help(e)
          else
            weather_query(e, query_msg)
          end
        end
      end
    end
  end
end
