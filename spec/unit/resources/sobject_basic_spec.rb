# frozen_string_literal: true

require 'spec_helper'
require_relative 'shared_examples'

describe Restforce::Resources::SObjectBasic do
  describe "#to_hash" do
    it_behaves_like 'an class that takes an optional body',
                    Restforce::Resources::SObjectBasic
  end

  describe ".build_option_url" do
    it_behaves_like 'build_option_url',
                    Restforce::Resources::SObjectBasic,
                    { sobject_name: 'Account',
                      api_version: '50' },
                    "/services/data/v50/sobjects/Account"
  end
end
