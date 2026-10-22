require "rails_helper"

RSpec.describe Api::V1::FetchWeatherDataService do
  let(:cache_provider) { FakeCacheProvider.new }

  it "requires a zip code" do
    service = described_class.call(zip_code: nil, cache_provider: cache_provider)

    expect(service.result).to be_nil
    expect(service.errors).to include("Zip code is required")
  end

  it "fetches weather on a cache miss and stores the result" do
    service = described_class.call(
      zip_code: "10001",
      country_code: "us",
      cache_provider: cache_provider,
      coordinates_provider: FakeCoordinatesProvider,
      weather_provider: FakeWeatherProvider
    )

    expect(service.cached).to be(false)
    expect(service.errors).to be_empty
    expect(service.result[:display_name]).to eq("New York")
    expect(service.result[:current_temperature]).to eq(20)
    expect(cache_provider.cache.read([ "weather", "10001", "us" ])).to eq(service.result)
  end

  it "returns the cached payload without calling providers" do
    payload = { current_temperature: 18, display_name: "Cached City" }
    cache_provider.cache.write([ "weather", "10001", "us" ], payload)

    service = described_class.call(
      zip_code: "10001",
      country_code: "us",
      cache_provider: cache_provider,
      coordinates_provider: ExplodingProvider,
      weather_provider: ExplodingProvider
    )

    expect(service.cached).to be(true)
    expect(service.result).to eq(payload)
  end

  it "does not cache errors" do
    service = described_class.call(
      zip_code: "00000",
      country_code: "us",
      cache_provider: cache_provider,
      coordinates_provider: ErrorCoordinatesProvider,
      weather_provider: ExplodingProvider
    )

    expect(service.cached).to be(false)
    expect(service.errors).to include("Location not found")
    expect(cache_provider.cache.read([ "weather", "00000", "us" ])).to be_nil
  end
end
