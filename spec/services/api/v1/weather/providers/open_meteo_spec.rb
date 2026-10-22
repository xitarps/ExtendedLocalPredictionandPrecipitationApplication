require "rails_helper"

RSpec.describe Api::V1::Weather::Providers::OpenMeteo do
  it "requires latitude and longitude" do
    service = described_class.call(latitude: nil, longitude: nil)

    expect(service.result).to be_nil
    expect(service.errors).to include("Latitude and longitude are required")
  end

  it "returns forecast data from Open-Meteo" do
    stub_open_meteo_success

    service = described_class.call(latitude: "40.7", longitude: "-74.0")

    expect(service.errors).to be_empty
    expect(service.result[:current_temperature]).to eq(20)
    expect(service.result[:today_high]).to eq(25)
    expect(service.result[:today_low]).to eq(10)
    expect(service.result[:extended_forecast]).to eq(
      [ { date: "01/01", high: 25, low: 10 } ]
    )
  end
end
