class Api::V1::Coordinates::FetcherService < ServiceInterface
  private

  def run
    self.errors << "Provider and zip code cannot be blank" if kwargs[:provider].blank? || kwargs[:zip_code].blank?

    data = kwargs[:provider].call(**(kwargs.slice(:zip_code, :country_code)))
    self.result = data.result
    self.errors += data.errors if data.errors.any?
  end
end
