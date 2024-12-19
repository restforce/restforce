# frozen_string_literal: true

require 'spec_helper'
require_relative 'shared_examples'

describe Restforce::Resources::Query do
  it_behaves_like 'a query resource',
                  Restforce::Resources::Query,
                  'query'
end
