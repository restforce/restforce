# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Client do
  subject { described_class }

  it { should < Restforce::AbstractClient }
  it { should < Restforce::Concerns::Picklists }
  it { should < Restforce::Concerns::Streaming }
  it { should < Restforce::Concerns::Canvas }
end
