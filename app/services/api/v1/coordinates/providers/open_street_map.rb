class Api::V1::Coordinates::Providers::OpenStreetMap < ServiceInterface
  BASE_URL = "https://nominatim.openstreetmap.org/search"
  DEFAULT_USER_AGENT = "MeuAppRailsPrevisaoTempo/1.0 (seu-email-de-contato@dominio.com)"
  DEFAULT_COUNTRY_CODE = "us"

  private

  def run
    check_zip_code_errors
    return if self.errors.any?

    uri = build_uri
    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = DEFAULT_USER_AGENT

    @response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    check_response_errors
    return if self.errors.any?

    begin
      @geo_data = JSON.parse(@response.body)
    rescue JSON::ParserError
      self.errors << "Invalid response from server - check the zip code"
    end
    return if self.errors.any?

    build_result
  end

  def build_uri
    uri = URI(BASE_URL)
    uri.query = URI.encode_www_form({
      postalcode: kwargs[:zip_code],
      countrycodes: kwargs[:country_code] || DEFAULT_COUNTRY_CODE,
      format: "json",
      limit: 1
    })
    uri
  end

  def build_result
    if @geo_data.any?
      location = @geo_data.first
      lat = location["lat"]
      lon = location["lon"]
      display_name = location["display_name"]
      self.result = { latitude: lat, longitude: lon, display_name: display_name }
    else
      self.errors << "Location not found"
      nil
    end
  end

  def check_zip_code_errors
    if kwargs[:zip_code].blank?
      self.errors << "Zip code cannot be blank"
    end

    kwargs[:zip_code] = kwargs[:zip_code].to_s.gsub(/\s+|-/, "").strip
    if kwargs[:zip_code].blank?
      self.errors << "Zip code cannot be blank"
    end

    true
  end

  def check_response_errors
    unless @response.is_a?(Net::HTTPSuccess)
      self.errors << "Server returned an error status: #{@response.code}"
    end
  end
end
