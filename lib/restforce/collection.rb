module Restforce
  class Collection < Array
    attr_reader :total_size, :next_page

    def initialize(hash, client)
      @client = client
      @total_size = hash['totalSize']
      @next_page  = hash['nextRecordsUrl']
      super(self.build(hash['records']))
    end

    # Converts an array of Hash's into an array of Restforce::SObject.
    def build(array)
      array.map { |record| Restforce::SObject.new(record, @client) }
    end

  end
end
