module Restforce
  class Collection
    include Enumerable

    # Given a hash and client, will create an Enumerator that will lazily
    # request Salesforce for the next page of results.
    def initialize(hash, client)
      @client = client
      @size = hash['totalSize']

      @pages = Enumerator.new do |ps|
        ps << hash
        next_page_url = hash['nextRecordsUrl']
        until next_page_url.nil?
          response = @client.get(next_page_url)
          ps << response.body
          next_page_url = response['nextRecordsUrl']
        end
      end
    end

    # Return the size of the Collection without making any additional requests.
    def size
      @size
    end
    alias_method :length, :size

    # Yeild each value on each page.
    def each
      @pages.each do |page|
        Restforce::Mash.build(page['records'], @client).each do |record|
          yield record
        end
      end
    end

    # Cache to_a so that we don't have to make the same request twice.
    def to_a
      @to_a ||= super
    end
  end
end
