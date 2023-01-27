# frozen_string_literal: true

require 'spec_helper'
require 'hashie/mash'

describe Restforce::Concerns::SObjectTreeAPI do
  let(:endpoint) { "composite/tree/Account" }
  let(:expected_tree) do
    { records: [{ :attributes => { type: "Account",
                                   referenceId: :acc1 },
                  :Name => "Widget Factory",
                  "Contacts" =>
                    { records: [{ :attributes =>
                                    { type: "Contact",
                                      referenceId: :contact1 },
                                  :FirstName => "John",
                                  :LastName => "Smith",
                                  :Email => "test@restforce.com",
                                  "Objects" =>
                                    { records: [{
                                      attributes:
                                        { type: "Object",
                                          referenceId: :obj1 },
                                      accountId: "@{acc1.Id}"
                                    }] } }] } },
                { attributes: { type: "Account",
                                referenceId: :acc2 },
                  Name: "Width Wholesalers" }] }
  end

  def create_tree(account)
    account.add(:acc1, Name: 'Widget Factory')
    account.embed('Contacts', 'Contact') do |contacts|
      contacts.add(:contact1,
                   FirstName: 'John',
                   LastName: 'Smith',
                   Email: 'test@restforce.com')
      contacts.embed("Objects", "Object") do |obj|
        obj.add(:obj1, accountId: '@{acc1.Id}')
      end
    end
    account.add(:acc2,
                Name: 'Width Wholesalers')
  end

  let(:response) do
    {
      hasErrors: false,
      results: [{
        referenceId: "acc1",
        id: "001D000000K0fXOIAZ"
      }, {
        referenceId: "contact1",
        id: "001D000000K0fXPIAZ"
      }, {
        referenceId: "obj1",
        id: "003D000000QV9n2IAD"
      }, {
        referenceId: "acc2",
        id: "003D000000QV9n3IAD"
      }]
    }
  end

  let(:response_with_error) do
    {
      hasErrors: true,
      results: [{
        referenceId: "contact1",
        errors: [{
          statusCode: "INVALID_EMAIL_ADDRESS",
          message: "Email: invalid email address: 123",
          fields: ["Email"]
        }]
      }]
    }
  end

  describe "#composite_tree" do
    it "posts to the endpoint with the tree created" do
      client.
        should_receive(:api_post).
        with(endpoint, expected_tree.to_json).
        and_return(Hashie::Mash.new(body: response))

      client.composite_tree('Account') do |account|
        create_tree(account)
      end
    end
  end

  describe Restforce::Concerns::SObjectTreeAPI::TreeBuilder do
    subject { Restforce::Concerns::SObjectTreeAPI::TreeBuilder }
    it "takes a root" do
      expect do
        subject.new
      end.to raise_error
    end

    describe "#tree" do
      it "should return a bare bone record hash when empty" do
        expect(subject.new('Account').tree).to eq({ records: [] })
      end

      it "should return a a record when populated" do
        tree = subject.new('Account').tap do |account|
          create_tree(account)
        end.tree

        expect(tree).to eq(expected_tree)
      end
    end
  end
end
