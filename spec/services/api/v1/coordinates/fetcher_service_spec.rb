require "rails_helper"

RSpec.describe Api::V1::Coordinates::FetcherService do
  it "returns the provider result" do
    service = described_class.call(
      provider: FakeCoordinatesProvider,
      zip_code: "10001",
      country_code: "us"
    )

    expect(service.errors).to be_empty
    expect(service.result[:latitude]).to eq("40.7")
    expect(service.result[:longitude]).to eq("-74.0")
  end

  it "propagates provider errors" do
    service = described_class.call(
      provider: ErrorCoordinatesProvider,
      zip_code: "00000"
    )

    expect(service.result).to be_nil
    expect(service.errors).to include("Location not found")
  end
end
