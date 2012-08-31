module Restforce
  class Collection < Array
    attr_reader :total_size, :next_page

    def initialize(hash)
      @total_size = hash['totalSize']
      @next_page  = hash['nextRecordsUrl']
      super(hash['records'])
    end

  end
end
