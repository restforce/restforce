require 'generator' if RUBY_VERSION =~ /\A1\.8/

module Restforce
  class Collection
    include Enumerable

    # Given a hash and client, will create an Enumerator that will lazily
    # request Salesforce for the next page of results.
    def initialize(hash, client)
      @client = client
      @page = hash
    end

    # Yeild each value on each page.
    def each
      @page['records'].each { |record| yield SObject.new(record, @client) }

      next_page.each { |record| yield record } if has_next_page?
    end

    # Return the size of the Collection without making any additional requests.
    def size
      @page['totalSize']
    end
    alias_method :length, :size

    # Return the current and all of the following pages.
    def pages
      [@page] + (has_next_page? ? next_page.pages : [])
    end

    # Returns true if there is a pointer to the next page.
    def has_next_page?
      !@page['nextRecordsUrl'].nil?
    end

    # Returns the next page if it's available, nil otherwise.
    def next_page
      @next_page ||= @client.get(@page['nextRecordsUrl']).body if has_next_page?
    end
  end
end
