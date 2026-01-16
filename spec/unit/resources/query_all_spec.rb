# frozen_string_literal: true

require 'spec_helper'
require_relative 'shared_examples'

describe Restforce::Resources::QueryAll do
  it_behaves_like 'a query resource',
                  Restforce::Resources::QueryAll,
                  'queryAll'
end
