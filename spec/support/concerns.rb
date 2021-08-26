# frozen_string_literal: true

module ConcernsExampleGroup
  def self.included(base)
    base.class_eval do
      let(:klass) do
        context = self
        Class.new { include context.described_class }
      end

      let(:client) { klass.new }

      subject { client }
    end
  end

  RSpec.configure do |config|
    config.include self, file_path: %r{spec/unit/concerns}
  end
end
