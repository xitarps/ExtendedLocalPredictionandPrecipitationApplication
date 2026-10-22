require "rails_helper"

RSpec.describe FetchWeatherDataJob do
  it "fetches weather and broadcasts the results" do
    weather = instance_double(
      Api::V1::FetchWeatherDataService,
      result: { display_name: "New York" },
      errors: [],
      cached: false
    )
    allow(Api::V1::FetchWeatherDataService).to receive(:call).and_return(weather)

    expect(Turbo::StreamsChannel).to receive(:broadcast_replace_to).with(
      "weather_abc",
      target: "weather_results",
      partial: "weather/results",
      locals: { weather: weather }
    )

    described_class.new.perform("weather_abc", "10001", "us")

    expect(Api::V1::FetchWeatherDataService).to have_received(:call).with(
      zip_code: "10001",
      country_code: "us",
      cache_provider: Rails
    )
  end
end
