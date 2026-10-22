class Api::V1::Weather::FetcherService < ServiceInterface
  private

  def run
    self.errors << "Provider, latitude and longitude cannot be blank" if kwargs[:provider].blank? || kwargs[:latitude].blank? || kwargs[:longitude].blank?
    data = kwargs[:provider].call(**(kwargs.slice(:latitude, :longitude)))
    self.result = data.result
    self.errors += data.errors if data.errors.any?
  end
end
