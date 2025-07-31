require 'active_model'

# to avoid deprecation warning:
# [deprecated] I18n.enforce_available_locales will default to true in the future. If you really want to skip validation of your locale you can set I18n.enforce_available_locales = false to avoid this message.
I18n.enforce_available_locales = false

require 'rspec/collection_matchers'

Dir['./spec/support/**/*'].each {|f| require f}

RSpec.configure do |config|
  config.order = 'random'

  config.expect_with :rspec
  config.mock_with :rspec
end
