require 'spec_helper'

describe Restforce::Tooling::Client do
  subject { described_class }

  it { should < Restforce::AbstractClient }
end
