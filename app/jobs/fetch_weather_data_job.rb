class FetchWeatherDataJob
  include Sidekiq::Job

  def perform(stream_name, zip_code, country_code)
    weather = Api::V1::FetchWeatherDataService.call(
      zip_code: zip_code,
      country_code: country_code,
      cache_provider: Rails
    )

    Turbo::StreamsChannel.broadcast_replace_to(
      stream_name,
      target: "weather_results",
      partial: "weather/results",
      locals: { weather: weather }
    )
  end
end
