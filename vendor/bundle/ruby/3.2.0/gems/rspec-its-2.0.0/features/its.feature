Feature: attribute of subject

  Scenario: specify value of a nested attribute
    Given a file named "example_spec.rb" with:
      """ruby
      class Person
        attr_reader :phone_numbers

        def initialize
          @phone_numbers = []
        end
      end

      RSpec.describe Person do
        context "with one phone number (555-1212)"do
          subject(:person) do
            person = Person.new
            person.phone_numbers << "555-1212"
            person
          end

          its("phone_numbers.first") { is_expected.to eq("555-1212") }
        end
      end
      """
    When I run rspec with the documentation option
    Then the output should contain:
      """
      Person
        with one phone number (555-1212)
          phone_numbers.first
            is expected to eq "555-1212"
      """

  Scenario: specify value of an attribute of a hash
    Given a file named "example_spec.rb" with:
      """ruby
      RSpec.describe Hash do
        context "with two items" do
          subject do
            {:one => 'one', :two => 'two'}
          end

          its(:size) { is_expected.to eq(2) }
        end
      end
      """
    When I run rspec
    Then the examples should all pass

  Scenario: specify value for key in a hash
    Given a file named "example_spec.rb" with:
      """ruby
      RSpec.describe Hash do
        context "with keys :one and 'two'" do
          subject do
            {:one => 1, "two" => 2}
          end

          its([:one]) { is_expected.to eq(1) }
          its(["two"]) { is_expected.to eq(2) }
        end
      end
      """
    When I run rspec
    Then the examples should all pass

  Scenario: specify value for key in a hash-like object
    Given a file named "example_spec.rb" with:
      """ruby
      require 'matrix'

      RSpec.describe Matrix do
        context "with values [[1, 2], [3, 4]]" do
          subject do
            Matrix[[1, 2], [3, 4]]
          end

          its([0, 1]) { are_expected.to eq(2) }
          its([1, 0]) { are_expected.to eq(3) }
          its([1, 2]) { are_expected.to be_nil }
        end
      end
      """
    When I run rspec
    Then the examples should all pass

 Scenario: failures are correctly reported as coming from the `its` line
    Given a file named "example_spec.rb" with:
      """ruby
      RSpec.describe Array do
        context "when first created" do
          its(:size) { is_expected.to_not eq(0) }
        end
      end
      """
    When I run rspec
    Then the output should contain "Failure/Error: its(:size) { is_expected.to_not eq(0) }"
    And the output should not match /#[^\n]*rspec[\x2f]its/

 Scenario: examples can be specified by exact line number
    Given a file named "example_spec.rb" with:
      """ruby
      RSpec.describe Array do
        context "when first created" do
          its(:size) { is_expected.to eq(0) }
        end
      end
      """
    When I run rspec specifying line number 3
    Then the examples should all pass

  Scenario: examples can be specified by line number within containing block
    Given a file named "example_spec.rb" with:
    """ruby
      RSpec.describe Array do
        context "when first created" do
          its(:size) { is_expected.to eq(0) }
        end

        it "should never execute this" do
          expect(true).to be(false)
        end
      end
      """
    When I run rspec specifying line number 2
    Then the examples should all pass

  Scenario: specify a method throws an exception
    Given a file named "example_spec.rb" with:
      """ruby
      class Klass
        def foo
          true
        end
      end

      RSpec.describe Klass do
        subject(:klass) { Klass.new }

        its(:foo) { will_not raise_error }
        its(:bar) { will raise_error(NoMethodError) }
      end
      """
    When I run rspec
    Then the examples should all pass

  Scenario: specify a method does not throw an exception
    Given a file named "example_spec.rb" with:
      """ruby
      class Klass; end

      RSpec.describe Klass do
        subject(:klass) { Klass.new }

        its(:foo) { will_not raise_error }
      end
      """
    When I run rspec
    Then the example should fail
    And the output should contain "Failure/Error: its(:foo) { will_not raise_error }"
    And the output should match /expected no Exception, got #<NoMethodError: undefined method [`']foo'/

  Scenario: examples will warn when using non block expectations
    Given a file named "example_spec.rb" with:
      """ruby
      class Klass
        def terminator
         "back"
        end
      end

      RSpec.describe Klass do
        subject(:arnie) { Klass.new }

        its(:terminator) { will be("back") }
      end
      """
    When I run rspec
    Then the example should fail
    And the output should contain "ArgumentError:" and "`will` only supports block expectations"
