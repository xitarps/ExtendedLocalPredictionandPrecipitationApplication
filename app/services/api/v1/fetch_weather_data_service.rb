class Api::V1::FetchWeatherDataService < ServiceInterface
  DEFAULT_COORDINATES_PROVIDER = Api::V1::Coordinates::Providers::OpenStreetMap
  DEFAULT_WEATHER_PROVIDER = Api::V1::Weather::Providers::OpenMeteo

  private

  def run
    self.errors << "Zip code is required" if kwargs[:zip_code].blank?

    return if self.errors.any?

    coordinates_params = kwargs.slice(:zip_code, :country_code)

    coordinates =  Api::V1::Coordinates::FetcherService.call(provider: kwargs[:coordinates_provider] || DEFAULT_COORDINATES_PROVIDER, **coordinates_params)
    self.errors += coordinates.errors if coordinates.errors.any?
    return if self.errors.any?


    weather_data = Api::V1::Weather::FetcherService.call(provider: kwargs[:weather_provider] || DEFAULT_WEATHER_PROVIDER, **coordinates.result.slice(:latitude, :longitude))
    self.errors += weather_data.errors if weather_data.errors.any?
    return if self.errors.any?

    self.result = weather_data.result.merge(coordinates.result.slice(:display_name))
  end
end
