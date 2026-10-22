class Api::V1::Weather::Providers::OpenMeteo < ServiceInterface
  BASE_URL = "https://api.open-meteo.com/v1/forecast"
  FORECAST_DAYS = 7

  private

  def run
    check_cordinates
    return if self.errors.any?

    response = fetch_weather_from_api
    return if self.errors.any?

    parsed_data = parse_response(response)
    return if self.errors.any?

    build_result(parsed_data)
  end

  def check_cordinates
    if kwargs[:latitude].blank? || kwargs[:longitude].blank?
      self.errors << "Latitude and longitude are required"
    end
  end

  def fetch_weather_from_api
    url_params = "latitude=#{kwargs[:latitude]}&longitude=#{kwargs[:longitude]}&current=temperature_2m&daily=temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=#{FORECAST_DAYS}"
    uri = URI("#{BASE_URL}?#{url_params}")

    response = Net::HTTP.get_response(uri)

    unless response.is_a?(Net::HTTPSuccess)
      self.errors << "Weather server returned an error: #{response.code}"
    end

    response
  rescue StandardError => e
    self.errors << "Weather connection failed: #{e.message}"
    nil
  end

  def parse_response(response)
    return nil if response.blank?

    JSON.parse(response.body)
  rescue JSON::ParserError
    self.errors << "Invalid JSON response from weather server"
    nil
  end

  def build_result(weather_data)
    return nil if weather_data.blank?

    if weather_data['current'].present? && weather_data['daily'].present?
      self.result = {
        current_temperature: weather_data['current']['temperature_2m'],
        today_high: weather_data['daily']['temperature_2m_max'].first,
        today_low: weather_data['daily']['temperature_2m_min'].first,
        extended_forecast: parse_extended_forecast(weather_data['daily'])
      }
    else
      self.errors << "No weather data available for these coordinates"
    end
  end

  def parse_extended_forecast(daily_data)
    daily_data['time'].each_with_index.map do |date, index|
      {
        date: Date.parse(date).strftime("%d/%m"),
        high: daily_data['temperature_2m_max'][index],
        low: daily_data['temperature_2m_min'][index]
      }
    end
  end
end