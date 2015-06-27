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
    config.include self, example_group: { file_path: %r{spec/unit/concerns} }
  end
end
