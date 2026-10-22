require "rails_helper"

RSpec.describe Api::V1::Coordinates::Providers::OpenStreetMap do
  it "requires a zip code" do
    service = described_class.call(zip_code: nil)

    expect(service.result).to be_nil
    expect(service.errors).to include("Zip code cannot be blank")
  end

  it "returns coordinates from OpenStreetMap" do
    stub_open_street_map_success

    service = described_class.call(zip_code: "10001", country_code: "us")

    expect(service.errors).to be_empty
    expect(service.result).to eq(
      latitude: "40.7",
      longitude: "-74.0",
      display_name: "New York, USA"
    )
  end

  it "adds an error when the location is missing" do
    stub_open_street_map_empty

    service = described_class.call(zip_code: "00000", country_code: "us")

    expect(service.result).to be_nil
    expect(service.errors).to include("Location not found")
  end
end
