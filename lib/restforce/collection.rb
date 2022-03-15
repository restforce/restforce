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
    def each(&block)
      @raw_page['records'].each { |record| yield Restforce::Mash.build(record, @client) }

      np = next_page
      while np
        np.current_page.each(&block)
        np = np.next_page
      end
    end

    # Return the size of each page in the collection
    def page_size
      @raw_page['records'].size
    end

    # Return the number of items in the Collection without making any additional
    # requests and going through all of the pages of results, one by one. Instead,
    # we can rely on the total count of results which Salesforce returns.
    def size
      @raw_page['totalSize'] || @raw_page['size']
    end
    alias length size

    def count(*args)
      # By default, `Enumerable`'s `#count` uses `#each`, which means going through all
      # of the pages of results, one by one. Instead, we can use `#size` which we have
      # already overridden to work in a smarter, more efficient way. This only works for
      # the simple version of `#count` with no arguments. When called with an argument or
      # a block, you need to know what the items in the collection actually are, so we
      # call `super` and end up iterating through each item in the collection.
      return size unless block_given? || !args.empty?

      super
    end

    # Returns true if the size of the Collection is zero.
    def empty?
      size.zero?
    end

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
