class Api::V1::FetchWeatherDataService < ServiceInterface
  DEFAULT_COORDINATES_PROVIDER = Api::V1::Coordinates::Providers::OpenStreetMap
  DEFAULT_WEATHER_PROVIDER = Api::V1::Weather::Providers::OpenMeteo
  CACHE_TTL = 30.minutes

  attr_reader :cached
  
  private

  def run
    self.errors << "Zip code is required" if kwargs[:zip_code].blank?
    return if self.errors.any?

    evaluate_cache
    return if @cached

    coordinates_params = kwargs.slice(:zip_code, :country_code)

    coordinates =  Api::V1::Coordinates::FetcherService.call(provider: kwargs[:coordinates_provider] || DEFAULT_COORDINATES_PROVIDER, **coordinates_params)
    self.errors += coordinates.errors if coordinates.errors.any?
    return if self.errors.any?


    weather_data = Api::V1::Weather::FetcherService.call(provider: kwargs[:weather_provider] || DEFAULT_WEATHER_PROVIDER, **coordinates.result.slice(:latitude, :longitude))
    self.errors += weather_data.errors if weather_data.errors.any?
    return if self.errors.any?

    self.result = weather_data.result.merge(coordinates.result.slice(:display_name))
    Rails.cache.write(@cache_key, self.result, expires_in: CACHE_TTL)
  end

  def evaluate_cache
    @cache_key = ["weather", kwargs[:zip_code], kwargs[:country_code]]
    cached_result = Rails.cache.read(@cache_key)

    return @cached = false if cached_result.nil?

    @cached = true
    self.result = cached_result
  end
end
