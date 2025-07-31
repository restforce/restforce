# frozen_string_literal: true

require 'rspec/its/subject'
require 'rspec/its/version'
require 'rspec/core'

RSpec::Core::ExampleGroup.define_example_method :__its_example

module RSpec
  # Adds the `its` to RSpec Example Groups, included by default.
  module Its
    # Creates a nested example group named by the submitted `attribute`,
    # and then generates an example using the submitted block.
    #
    # @example
    #
    #   # This ...
    #   RSpec.describe Array do
    #     its(:size) { is_expected.to eq(0) }
    #   end
    #
    #   # ... generates the same runtime structure as this:
    #   RSpec.describe Array do
    #     describe "size" do
    #       it "is_expected.to eq(0)" do
    #         expect(subject.size).to eq(0)
    #       end
    #     end
    #   end
    #
    # The attribute can be a `Symbol` or a `String`. Given a `String`
    # with dots, the result is as though you concatenated that `String`
    # onto the subject in an expression.
    #
    # @example
    #
    #   RSpec.describe Person do
    #     subject(:person) do
    #       Person.new.tap do |person|
    #         person.phone_numbers << "555-1212"
    #       end
    #     end
    #
    #     its("phone_numbers.first") { is_expected.to eq("555-1212") }
    #   end
    #
    # When the subject is a `Hash`, you can refer to the Hash keys by
    # specifying a `Symbol` or `String` in an array.
    #
    # @example
    #
    #   RSpec.describe "a configuration Hash" do
    #     subject do
    #       { :max_users => 3,
    #         'admin' => :all_permissions.
    #         'john_doe' => {:permissions => [:read, :write]}}
    #     end
    #
    #     its([:max_users]) { is_expected.to eq(3) }
    #     its(['admin']) { is_expected.to eq(:all_permissions) }
    #     its(['john_doe', :permissions]) { are_expected.to eq([:read, :write]) }
    #
    #     # You can still access its regular methods this way:
    #     its(:keys) { is_expected.to include(:max_users) }
    #     its(:count) { is_expected.to eq(2) }
    #   end
    #
    # With an implicit subject, `should` can be used as an alternative
    # to `is_expected` (e.g. for one-liner use). An `are_expected` alias is also
    # supplied.
    #
    # @example
    #
    #   RSpec.describe Array do
    #     its(:size) { should eq(0) }
    #   end
    #
    # With an implicit subject, `will` can be used as an alternative
    # to `expect { subject.attribute }.to matcher` (e.g. for one-liner use).
    #
    # @example
    #
    #   RSpec.describe Array do
    #     its(:foo) { will raise_error(NoMethodError) }
    #   end
    #
    # With an implicit subject, `will_not` can be used as an alternative
    # to `expect { subject.attribute }.to_not matcher` (e.g. for one-liner use).
    #
    # @example
    #
    #   RSpec.describe Array do
    #     its(:size) { will_not raise_error }
    #   end
    #
    # You can pass more than one argument on the `its` block to add
    # some metadata to the generated example
    #
    # @example
    #
    #   # This ...
    #   RSpec.describe Array do
    #     its(:size, :focus) { is_expected.to eq(0) }
    #   end
    #
    #   # ... generates the same runtime structure as this:
    #   RSpec.describe Array do
    #     describe "size" do
    #       it "is expected to eq(0)", :focus do
    #         expect(subject.size).to eq(0)
    #       end
    #     end
    #   end
    #
    # Note that this method does not modify `subject` in any way, so if you
    # refer to `subject` in `let` or `before` blocks, you're still
    # referring to the outer subject.
    #
    # @example
    #
    #   RSpec.describe Person do
    #     subject { Person.new }
    #
    #     before { subject.age = 25 }
    #
    #     its(:age) { is_expected.to eq(25) }
    #   end
    def its(attribute, *options, &block)
      its_caller = caller.grep_v(%r{/lib/rspec/its})

      describe(attribute.to_s, caller: its_caller) do
        let(:__its_subject) { RSpec::Its::Subject.for(attribute, subject) }

        def is_expected
          expect(__its_subject)
        end
        alias_method :are_expected, :is_expected

        def will(matcher = nil, message = nil)
          raise ArgumentError, "`will` only supports block expectations" unless matcher.supports_block_expectations?

          expect { __its_subject }.to matcher, message
        end

        def will_not(matcher = nil, message = nil)
          raise ArgumentError, "`will_not` only supports block expectations" unless matcher.supports_block_expectations?

          expect { __its_subject }.to_not matcher, message
        end

        def should(matcher = nil, message = nil)
          RSpec::Expectations::PositiveExpectationHandler.handle_matcher(__its_subject, matcher, message)
        end

        def should_not(matcher = nil, message = nil)
          RSpec::Expectations::NegativeExpectationHandler.handle_matcher(__its_subject, matcher, message)
        end

        options << {} unless options.last.is_a?(Hash)
        options.last.merge!(caller: its_caller)

        __its_example(nil, *options, &block)
      end
    end
  end
end

RSpec.configure do |rspec|
  rspec.extend RSpec::Its
  rspec.backtrace_exclusion_patterns << %r{/lib/rspec/its}
end

RSpec::SharedContext.send(:include, RSpec::Its)
