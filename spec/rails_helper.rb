require "spec_helper"
ENV["RAILS_ENV"] = "test"
require_relative "../config/environment"
abort("The Rails environment is running in #{Rails.env} mode!") unless Rails.env.test?
require "rspec/rails"
require "webmock/rspec"

Rails.root.glob("spec/support/**/*.rb").sort.each { |f| require f }

Sidekiq.testing!(:fake)

RSpec.configure do |config|
  config.use_active_record = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.before { Sidekiq::Job.clear_all }
end

WebMock.disable_net_connect!(allow_localhost: true)
