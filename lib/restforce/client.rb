module Restforce
  class Client < AbstractClient
    include Restforce::Concerns::Streaming
    include Restforce::Concerns::Picklists
    include Restforce::Concerns::Canvas

    # Public: Returns a url to the resource.
    #
    # resource - A record that responds to to_sparam or a String/Fixnum.
    #
    # Returns the url to the resource.
    def url(resource)
      "#{instance_url}/#{(resource.respond_to?(:to_sparam) ? resource.to_sparam : resource)}"
    end
  end
end
