# frozen_string_literal: true

require 'spec_helper'

describe Restforce::AbstractClient do
  subject { described_class }

  it { should < Restforce::Concerns::Base }
  it { should < Restforce::Concerns::Connection }
  it { should < Restforce::Concerns::Authentication }
  it { should < Restforce::Concerns::Caching }
  it { should < Restforce::Concerns::API }
end
