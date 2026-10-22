module ApiStubs
  def stub_open_street_map_success(zip_code: "10001")
    stub_request(:get, "https://nominatim.openstreetmap.org/search")
      .with(query: hash_including("postalcode" => zip_code))
      .to_return(
        status: 200,
        body: [ { "lat" => "40.7", "lon" => "-74.0", "display_name" => "New York, USA" } ].to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  def stub_open_street_map_empty(zip_code: "00000")
    stub_request(:get, "https://nominatim.openstreetmap.org/search")
      .with(query: hash_including("postalcode" => zip_code))
      .to_return(
        status: 200,
        body: [].to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  def stub_open_meteo_success
    stub_request(:get, %r{https://api.open-meteo.com/v1/forecast})
      .to_return(
        status: 200,
        body: {
          "current" => { "temperature_2m" => 20 },
          "daily" => {
            "time" => [ "2026-01-01" ],
            "temperature_2m_max" => [ 25 ],
            "temperature_2m_min" => [ 10 ]
          }
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end
end

RSpec.configure do |config|
  config.include ApiStubs
end
