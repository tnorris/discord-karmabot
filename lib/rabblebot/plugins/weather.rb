require 'open-uri'
require 'json'

class RabbleBot
  attr_reader :google_api, :forecastio_api
  
  module RabbleBotPlugin
    # a weather plugin
    class Weather < BasicPlugin
      def initialize(bot)
        super(bot)
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
        gmaps_json_response = open("https://maps.googleapis.com/maps/api/geocode/json?address=#{message}&key=#{@google_api}").read
        gmaps_json = JSON.parse(gmaps_json_response)
        
        location = gmaps_json['results'][0]['formatted_address']
        lat = gmaps_json['results'][0]['geometry']['location']['lat']
        lng = gmaps_json['results'][0]['geometry']['location']['lng']
        
        forecast_io_response = open("https://api.forecast.io/forecast/#{@forecastio_api}/#{lat},#{lng}").read
        forecast_io_json = JSON.parse(forecast_io_response)
        
        icon = forecast_io_json['currently']['icon']
        status = forecast_io_json['currently']['summary']
        temp = forecast_io_json['currently']['temperature']
        humidity = forecast_io_json['currently']['humidity'].to_f
        humidity = (humidity*100).to_i
        windSpeed = forecast_io_json['currently']['windSpeed']
        cloudCover = forecast_io_json['currently']['cloudCover'].to_f
        cloudCover = (cloudCover*100).to_i
        emoji = ''
        
        case icon
          when 'clear-night', 'clear-day'
            emoji = ':waxing_gibbous_moon:'
          when 'partly-cloudy-night', 'partly-cloudy-day'
            emoji = ':partly_sunny:'
          when 'rain'
            emoji = ':cloud_rain:'
          when 'snow'
            emoji = ':cloud_snow:'
          when 'sleet'
            emoji = ':cloud_rain:'
          when 'wind'
            emoji = ':wind_blowing_face:'
          when 'fog'
            emoji = ':foggy:'
          when 'cloudy'
            emoji = ':cloud:'
          when 'tornado'
            emoji = ':cloud_tornado:'
          when 'thunderstorm'
            emoji = ':cloud_lightning:'
        end
        
        r = "\n*Current Weather for #{location}:*\nStatus: #{status} #{emoji}\nTemperature: #{temp} F\nHumidity: #{humidity}%\nWind Speed: #{windSpeed} mph\nCloud Cover: #{cloudCover}%"
        e.respond r
        
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
