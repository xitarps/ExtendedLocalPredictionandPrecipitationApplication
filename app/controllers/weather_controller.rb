class WeatherController < ApplicationController
  def index
    return if params["zip_code"].blank?

    @weather_stream = "weather_#{SecureRandom.uuid}"
  end

  def enqueue
    FetchWeatherDataJob.perform_async(
      params["stream_name"],
      params["zip_code"],
      params["country_code"]
    )
    head :accepted
  end
end
