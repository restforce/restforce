# frozen_string_literal: true

RSpec::Matchers.define :include_picklist_values do |expected|
  match do |actual|
    actual.all? { |picklist_value| expected.include? picklist_value['value'] }
  end
end

RSpec::Matchers.define :have_client do |expected|
  match do |actual|
    actual.instance_variable_get(:@client) == expected
  end
end
