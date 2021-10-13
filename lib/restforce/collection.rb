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

    # Return the size of the Collection without making any additional requests.
    def size
      @raw_page['totalSize']
    end
    alias length size

    def count(*args)
      # Enumerable's only interface is #each and thus Enumerable#count's default 
      # implementation does not check for and delegate to #size on an argument and 
      # blockless call. Therefore somebody calling #count instead of #size on the 
      # collection would load and iterate the entire collection, despite us already 
      # having the answer to that question available. So we optimize for this case here
      # and protect the user from this easy mistake.
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
