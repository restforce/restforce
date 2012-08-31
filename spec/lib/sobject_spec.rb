require 'spec_helper'

describe Restforce::SObject do
  describe '#new' do
    context 'with valid options' do
      let(:record) do
        described_class.new(JSON.parse(fixture('sobject/query_success_response'))['records'].first)
      end

      subject            { record }
      it                 { should be_a Restforce::SObject }
      its(:sobject_type) { should eq 'Whizbang' }
      its(:Text_Label)   { should eq 'Hi there!' }
    end
  end
end
