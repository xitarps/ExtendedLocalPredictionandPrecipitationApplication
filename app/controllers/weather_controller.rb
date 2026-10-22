class WeatherController < ApplicationController
  def index
    @weather = Api::V1::FetchWeatherDataService.call(
      zip_code: params["zip_code"],
      country_code: params["country_code"]
    )
  end
end
