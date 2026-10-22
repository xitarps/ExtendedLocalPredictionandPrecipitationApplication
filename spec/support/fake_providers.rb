class FakeServiceResult
  attr_reader :result, :errors

  def initialize(result: nil, errors: [])
    @result = result
    @errors = errors
  end
end

class FakeCoordinatesProvider
  def self.call(**)
    FakeServiceResult.new(
      result: { latitude: "40.7", longitude: "-74.0", display_name: "New York" }
    )
  end
end

class FakeWeatherProvider
  def self.call(**)
    FakeServiceResult.new(
      result: {
        current_temperature: 20,
        today_high: 25,
        today_low: 10,
        extended_forecast: [ { date: "01/01", high: 25, low: 10 } ]
      }
    )
  end
end

class ErrorCoordinatesProvider
  def self.call(**)
    FakeServiceResult.new(errors: [ "Location not found" ])
  end
end

class ExplodingProvider
  def self.call(**)
    raise "provider should not be called"
  end
end
