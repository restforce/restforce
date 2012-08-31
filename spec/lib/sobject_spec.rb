require 'spec_helper'

describe Restforce::SObject do
  describe '#new' do
    context 'with valid options' do
      let(:record) do
        described_class.new('attributes' => { 'type' => 'Foo' }, 'Id' => '1234')
      end

      subject            { record }
      it                 { should be_a Restforce::SObject }
      its(:sobject_type) { should eq 'Foo' }
      its(:Id)           { should eq '1234' }
    end
  end
end
