require "rails_helper"

RSpec.describe "Weather", type: :request do
  let(:headers) { { "User-Agent" => ModernBrowser::USER_AGENT } }

  it "shows loading without enqueueing the job" do
    expect {
      get weather_index_path, params: { zip_code: "10001", country_code: "us" }, headers: headers
    }.not_to change(FetchWeatherDataJob.jobs, :size)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("loading...")
    expect(response.body).to include("turbo-cable-stream-source")
  end

  it "enqueues the job after the cable is ready" do
    expect {
      post weather_enqueue_path,
           params: { stream_name: "weather_abc", zip_code: "10001", country_code: "us" },
           headers: headers
    }.to change(FetchWeatherDataJob.jobs, :size).by(1)

    expect(response).to have_http_status(:accepted)
  end
end
