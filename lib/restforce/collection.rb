# frozen_string_literal: true

module Restforce
  class Collection
    include Enumerable

    # Given a hash and client, will create an Enumerator that will lazily
    # request Salesforce for the next page of results.
    def initialize(hash, client)
      @client = client
      @raw_page = hash
    end

    # Yield each value on each page.
    def each
      @raw_page['records'].each { |record| yield Restforce::Mash.build(record, @client) }

      np = next_page
      while np
        np.current_page.each { |record| yield record }
        np = np.next_page
      end
    end

    # Return the size of each page in the collection
    def page_size
      @raw_page['records'].size
    end

    # Return the size of the Collection without making any additional requests.
    def size
      @raw_page['totalSize']
    end
    alias length size

    # Return array of the elements on the current page
    def current_page
      first(@raw_page['records'].size)
    end

    # Return the current and all of the following pages.
    def pages
      [self] + (has_next_page? ? next_page.pages : [])
    end

    # Returns true if there is a pointer to the next page.
    def has_next_page?
      !@raw_page['nextRecordsUrl'].nil?
    end

    # Returns the next page as a Restforce::Collection if it's available, nil otherwise.
    def next_page
      @client.get(@raw_page['nextRecordsUrl']).body if has_next_page?
    end
  end
end
