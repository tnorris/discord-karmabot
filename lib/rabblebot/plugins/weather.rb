require 'open-uri'
require 'json'

# a weather plugin
class RabbleBot
  attr_accessor :google_api, :forecastio_api
  module RabbleBotPlugin
    class Weather < BasicPlugin
      def initialize(bot, config)
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
        gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{message}&key=#{@google_api}"
        gmaps_json_response = open(gmaps_url).read
        gmaps_json = JSON.parse(gmaps_json_response)
        location = gmaps_json['results'][0]['formatted_address']
        lat = gmaps_json['results'][0]['geometry']['location']['lat']
        lng = gmaps_json['results'][0]['geometry']['location']['lng']
        forecast_url = "https://api.forecast.io/forecast/#{@forecastio_api}/#{lat},#{lng}"
        forecast_io_response = open(forecast_url).read
        forecast_io_json = JSON.parse(forecast_io_response)
        icon = forecast_io_json['currently']['icon']
        status = forecast_io_json['currently']['summary']
        temp = forecast_io_json['currently']['temperature']
        humidity = forecast_io_json['currently']['humidity'].to_f
        humidity = (humidity * 100).to_i
        windspeed = forecast_io_json['currently']['windSpeed']
        cloudcover = forecast_io_json['currently']['cloudCover'].to_f
        cloudcover = (cloudcover * 100).to_i
        emoji = ":#{@config[emojis].fetch(icon, 'no emoji')}:"
        response = <<-EOT.gsub(/^\s+/, '')
          *Current Weather for #{location}:*
          Status: #{status} #{emoji}
          Temperature: #{temp} F
          Humidity: #{humidity}%
          Wind Speed: #{windspeed} mph
          Cloud Cover: #{cloudcover}%
        EOT
        e.respond response
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
