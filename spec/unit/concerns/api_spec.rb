require 'spec_helper'

describe Restforce::Concerns::API do
  let(:response) { double('Faraday::Response', :body => double('Body')) }

  describe '.list_sobjects' do
    subject { client.list_sobjects }

    before do
      client.stub :describe => [ { 'name' => 'foo' } ]
    end

    it { should eq ['foo'] }
  end

  describe '.describe' do
    subject(:describe) { client.describe }

    it 'returns the global describe' do
      sobjects = double('sobjects')
      response.body.stub(:[]).with('sobjects').and_return(sobjects)
      client.should_receive(:api_get).
        with('sobjects').
        and_return(response)
      expect(describe).to eq sobjects
    end

    context 'when given the name of an sobject' do
      subject(:describe) { client.describe('Whizbang') }

      it 'returns the full describe' do
        client.should_receive(:api_get).
          with('sobjects/Whizbang/describe').
          and_return(response)
        expect(describe).to eq response.body
      end
    end
  end

  describe '.describe_layouts' do
    subject(:describe_layouts) { client.describe_layouts('Whizbang') }

    it 'returns the layouts for the sobject' do
      client.should_receive(:api_get).
        with('sobjects/Whizbang/describe/layouts').
        and_return(response)
      expect(describe_layouts).to eq response.body
    end

    context 'when given the id of a layout' do
      subject(:describe_layouts) { client.describe_layouts('Whizbang', '012E0000000RHEp') }

      it 'returns the describe for the specified layout' do
        client.should_receive(:api_get).
          with('sobjects/Whizbang/describe/layouts/012E0000000RHEp').
          and_return(response)
        expect(describe_layouts).to eq response.body
      end
    end
  end

  describe '.org_id' do
    subject(:org_id) { client.org_id }

    it 'returns the organization id' do
      organizations = [ { 'Id' => 'foo' } ]
      client.should_receive(:query).
        with('select id from Organization').
        and_return(organizations)
      expect(org_id).to eq 'foo'
    end
  end

  describe '.query' do
    let(:soql)        { 'Select Id from Account' }
    subject(:results) { client.query(soql) }

    context 'with mashify middleware' do
      before do
        client.stub :mashify? => true
      end

      it 'returns the body' do
        client.should_receive(:api_get).
          with('query', :q => soql).
          and_return(response)
        expect(results).to eq response.body
      end
    end

    context 'without mashify middleware' do
      before do
        client.stub :mashify? => false
      end

      it 'returns the records attribute of the body' do
        records = double('records')
        response.body.stub(:[]).
          with('records').
          and_return(records)
        client.should_receive(:api_get).
          with('query', :q => soql).
          and_return(response)
        expect(results).to eq records
      end
    end
  end

  describe '.search' do
    let(:sosl)        { 'FIND {bar}' }
    subject(:results) { client.search(sosl) }

    it 'performs a sosl search' do
      client.should_receive(:api_get).
        with('search', :q => sosl).
        and_return(response)
      expect(results).to eq response.body
    end
  end

  [:create, :update, :upsert, :destroy].each do |method|
    describe ".#{method}" do
      let(:args)       { [] }
      subject(:result) { client.send(method, *args) }

      it "delegates to :#{method}!" do
        client.should_receive(:"#{method}!").
          with(*args).
          and_return(response)
        expect(result).to eq response
      end

      it 'rescues exceptions' do
        [Faraday::Error::ClientError].each do |exception_klass|
          client.should_receive(:"#{method}!").
            with(*args).
            and_raise(exception_klass.new(nil))
          expect(result).to eq false
        end
      end
    end
  end

  describe '.create!' do
    let(:sobject)    { 'Whizbang' }
    let(:attrs)      { Hash.new }
    subject(:result) { client.create!(sobject, attrs) }

    it 'send an HTTP POST, and returns the id of the record' do
      response.body.stub(:[]).with('id').and_return('1234')
      client.should_receive(:api_post).
        with('sobjects/Whizbang', attrs).
        and_return(response)
      expect(result).to eq '1234'
    end
  end

  describe '.update!' do
    let(:sobject)    { 'Whizbang' }
    let(:attrs)      { Hash.new }
    subject(:result) { client.update!(sobject, attrs) }

    context 'when the id field is present' do
      let(:attrs) { { :id => '1234' } }

      it 'sends an HTTP PATCH, and returns true' do
        client.should_receive(:api_patch).
          with('sobjects/Whizbang/1234', attrs)
        expect(result).to be_true
      end
    end

    context 'when the id field is missing from the attrs' do
      subject { lambda { result }}
      it { should raise_error ArgumentError, 'Id field missing from attrs.' }
    end
  end

  describe '.upsert!' do
    let(:sobject)    { 'Whizbang' }
    let(:field)      { :External_ID__c }
    let(:attrs)      { { 'External_ID__c' => '1234' } }
    subject(:result) { client.upsert!(sobject, field, attrs) }

    context 'when the record is found and updated' do
      it 'returns true' do
        response.body.stub :[]
        client.should_receive(:api_patch).
          with('sobjects/Whizbang/External_ID__c/1234', {}).
          and_return(response)
        expect(result).to be_true
      end
    end

    context 'when the record is found and created' do
      it 'returns the id of the record' do
        response.body.stub(:[]).with('id').and_return('4321')
        client.should_receive(:api_patch).
          with('sobjects/Whizbang/External_ID__c/1234', {}).
          and_return(response)
        expect(result).to eq '4321'
      end
    end
  end

  describe '.destroy!' do
    let(:id)         { '1234' }
    let(:sobject)    { 'Whizbang' }
    subject(:result) { client.destroy!(sobject, id) }

    it 'sends and HTTP delete, and returns true' do
      client.should_receive(:api_delete).
        with('sobjects/Whizbang/1234')
      expect(result).to be_true
    end
  end

  describe '.find' do
    let(:sobject)    { 'Whizbang' }
    let(:id)         { '1234' }
    let(:field)      { nil }
    subject(:result) { client.find(sobject, id, field) }

    context 'when no external id is specified' do
      it 'returns the full representation of the object' do
        client.should_receive(:api_get).
          with('sobjects/Whizbang/1234').
          and_return(response)
        expect(result).to eq response.body
      end
    end

    context 'when an external id is specified' do
      let(:field) { :External_ID__c }

      it 'returns the full representation of the object' do
        client.should_receive(:api_get).
          with('sobjects/Whizbang/External_ID__c/1234').
          and_return(response)
        expect(result).to eq response.body
      end
    end
  end
end