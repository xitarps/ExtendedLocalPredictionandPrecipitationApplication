require "rails_helper"

RSpec.describe Api::V1::Weather::FetcherService do
  it "returns the provider result" do
    service = described_class.call(
      provider: FakeWeatherProvider,
      latitude: "40.7",
      longitude: "-74.0"
    )

    expect(service.errors).to be_empty
    expect(service.result[:current_temperature]).to eq(20)
  end
end
