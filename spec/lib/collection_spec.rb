require 'spec_helper'

describe Restforce::Collection do
  describe '#new' do
    context 'without pagination' do
      let(:records) do
        described_class.new(JSON.parse(fixture('sobject/query_success_response')))
      end

      subject          { records }
      it               { should respond_to :each }
      its(:size)       { should eq 1}
      its(:total_size) { should eq 1}
      its(:next_page)  { should be_nil }
    end
  end
end
