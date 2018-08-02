# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    EventMachine.stub(:connect) if defined?(EventMachine)
  end

  config.filter_run_excluding event_machine: true if RUBY_PLATFORM == 'java'

  config.around event_machine: true do |example|
    EM.run {
      example.run
      EM.stop
    }
  end
end
