require "rails_helper"

RSpec.describe "Weather", type: :request do
  it "renders forecast data from the APIs" do
    stub_open_street_map_success
    stub_open_meteo_success

    get weather_index_path,
        params: { zip_code: "10001", country_code: "us" },
        headers: { "User-Agent" => ModernBrowser::USER_AGENT }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("New York, USA")
    expect(response.body).to include("not from cache")
  end
end
