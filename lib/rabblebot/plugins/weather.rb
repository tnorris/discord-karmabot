require 'open-uri'
require 'json'

# a weather plugin
class RabbleBot
  attr_reader :google_api, :forecastio_api
  module RabbleBotPlugin
    # a weather plugin
    class Weather < BasicPlugin
      def initialize(bot, config)
        super(bot, config)
        @bot.info 'Loading Weather Plugin'
        @google_api = 'YOUR_GOOGLEAPI_KEY'
        @forecastio_api = 'YOUR_FORECAST_IO_API_KEY'
        add_weather_handler
        @bot.info 'Weather Plugin loaded!'
      end

      def weather_help(e)
        e.respond '/weather ZIP - tells you what the weather of ZIP is.'
      end

      def weather_query(e, message)
        gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{message}&key=#{@google_api}"
        gmaps_json_response = open('#{gmaps_json_url}').read
        gmaps_json = JSON.parse(gmaps_json_response)
        location = gmaps_json['results'][0]['formatted_address']
        lat = gmaps_json['results'][0]['geometry']['location']['lat']
        lng = gmaps_json['results'][0]['geometry']['location']['lng']
        forecast_url = "https://api.forecast.io/forecast/#{@forecastio_api}/#{lat},#{lng}"
        forecast_io_response = open('#{forecast_io_url}').read
        forecast_io_json = JSON.parse(forecast_io_response)
        icon = forecast_io_json['currently']['icon']
        status = forecast_io_json['currently']['summary']
        temp = forecast_io_json['currently']['temperature']
        humidity = forecast_io_json['currently']['humidity'].to_f
        humidity = (humidity * 100).to_i
        windspeed = forecast_io_json['currently']['windSpeed']
        cloudcover = forecast_io_json['currently']['cloudCover'].to_f
        cloudcover = (cloudcover * 100).to_i
        icon_table = {'clear-night' => 'sunrise_over_mountains',
                      'clear-day' => 'waxing_gibbous_moon',
                      'partly-cloudy-night' => 'partly_sunny',
                      'partly-cloudy-day' => 'partly_sunny',
                      'rain' => 'cloud_rain',
                      'snow' => 'cloud_snow',
                      'sleet' => 'cloud_rain',
                      'wind' => 'wind_blowing_face',
                      'fog' => 'foggy',
                      'cloudy' => 'cloud',
                      'tornado' => 'cloud_tornado',
                      'thunderstorm' => 'cloud_lightning'}
        emoji = ":#{icon_table.fetch(icon, "no emoji")}:"
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
