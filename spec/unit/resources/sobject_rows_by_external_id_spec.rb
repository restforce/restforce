# frozen_string_literal: true

require 'spec_helper'
require_relative 'shared_examples'

describe Restforce::Resources::SObjectRowsByExternalId do
  describe "#to_hash" do
    it_behaves_like 'an class that takes an optional body',
                    Restforce::Resources::SObjectRowsByExternalId
  end

  describe ".build_option_url" do
    it_behaves_like 'build_option_url',
                    Restforce::Resources::SObjectRowsByExternalId,
                    {
                      sobject_name: 'Contact',
                      api_version: '50',
                      field_value: 'foo@bar.com',
                      field_name: 'Email'
                    },
                    "/services/data/v50/sobjects/Contact/Email/foo@bar.com"
  end
end
