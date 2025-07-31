# frozen_string_literal: true
require 'cgi'
require 'uri'

module CookieJar
  # Represents a set of cookie validation errors
  class InvalidCookieError < StandardError
    # [Array<String>] the specific validation issues encountered
    attr_reader :messages

    # Create a new instance
    # @param [String, Array<String>] the validation issue(s) encountered
    def initialize(message)
      if message.is_a? Array
        @messages = message
        message = message.join ', '
      else
        @messages = [message]
      end
      super message
    end
  end

  # Contains logic to parse and validate cookie headers
  module CookieValidation
    # REGEX cookie matching
    module PATTERN
      include URI::REGEXP::PATTERN

      TOKEN = '[^(),\/<>@;:\\\"\[\]?={}\s]+'.freeze
      VALUE1 = '([^;]*)'.freeze
      IPADDR = "#{IPV4ADDR}|#{IPV6ADDR}".freeze
      BASE_HOSTNAME = "(?:#{DOMLABEL}\\.)(?:((?:(?:#{DOMLABEL}\\.)+(?:#{TOPLABEL}\\.?))|local))".freeze

      QUOTED_PAIR = '\\\\[\\x00-\\x7F]'.freeze
      LWS = '\\r\\n(?:[ \\t]+)'.freeze
      # TEXT="[\\t\\x20-\\x7E\\x80-\\xFF]|(?:#{LWS})"
      QDTEXT = "[\\t\\x20-\\x21\\x23-\\x7E\\x80-\\xFF]|(?:#{LWS})".freeze
      QUOTED_TEXT = "\\\"(?:#{QDTEXT}|#{QUOTED_PAIR})*\\\"".freeze
      VALUE2 = "#{TOKEN}|#{QUOTED_TEXT}".freeze
    end
    BASE_HOSTNAME = /#{PATTERN::BASE_HOSTNAME}/
    BASE_PATH = %r{\A((?:[^/?#]*/)*)}
    IPADDR = /\A#{PATTERN::IPV4ADDR}\Z|\A#{PATTERN::IPV6ADDR}\Z/
    HDN = /\A#{PATTERN::HOSTNAME}\Z/
    TOKEN = /\A#{PATTERN::TOKEN}\Z/
    PARAM1 = /\A(#{PATTERN::TOKEN})(?:=#{PATTERN::VALUE1})?\Z/
    PARAM2 = Regexp.new("(#{PATTERN::TOKEN})(?:=(#{PATTERN::VALUE2}))?(?:\\Z|;)", Regexp::NOENCODING)
    # TWO_DOT_DOMAINS = /\A\.(com|edu|net|mil|gov|int|org)\Z/

    # Converts the input object to a URI (if not already a URI)
    #
    # @param [String, URI] request_uri URI we are normalizing
    # @param [URI] URI representation of input string, or original URI
    def self.to_uri(request_uri)
      (request_uri.is_a? URI) ? request_uri : (URI.parse request_uri)
    end

    # Converts an input cookie or uri to a string representing the path.
    # Assume strings are already paths
    #
    # @param [String, URI, Cookie] object containing the path
    # @return [String] path information
    def self.to_path(uri_or_path)
      if (uri_or_path.is_a? URI) || (uri_or_path.is_a? Cookie)
        uri_or_path.path
      else
        uri_or_path
      end
    end

    # Converts an input cookie or uri to a string representing the domain.
    # Assume strings are already domains. Value may not be an effective host.
    #
    # @param [String, URI, Cookie] object containing the domain
    # @return [String] domain information.
    def self.to_domain(uri_or_domain)
      if uri_or_domain.is_a? URI
        uri_or_domain.host
      elsif uri_or_domain.is_a? Cookie
        uri_or_domain.domain
      else
        uri_or_domain
      end
    end

    # Compare a tested domain against the base domain to see if they match, or
    # if the base domain is reachable.
    #
    # @param [String] tested_domain domain to be tested against
    # @param [String] base_domain new domain being tested
    # @return [String,nil] matching domain on success, nil on failure
    def self.domains_match(tested_domain, base_domain)
      base = effective_host base_domain
      search_domains = compute_search_domains_for_host base
      search_domains.find do |domain|
        domain == tested_domain
      end
    end

    # Compute the reach of a hostname (RFC 2965, section 1)
    # Determines the next highest superdomain
    #
    # @param [String,URI,Cookie] hostname hostname, or object holding hostname
    # @return [String,nil] next highest hostname, or nil if none
    def self.hostname_reach(hostname)
      host = to_domain hostname
      host = host.downcase
      match = BASE_HOSTNAME.match host
      match[1] if match
    end

    # Compute the base of a path, for default cookie path assignment
    #
    # @param [String, URI, Cookie] path, or object holding path
    # @return base path (all characters up to final '/')
    def self.cookie_base_path(path)
      BASE_PATH.match(to_path(path))[1]
    end

    # Processes cookie path data using the following rules:
    # Paths are separated by '/' characters, and accepted values are truncated
    # to the last '/' character. If no path is specified in the cookie, a path
    # value will be taken from the request URI which was used for the site.
    #
    # Note that this will not attempt to detect a mismatch of the request uri
    # domain and explicitly specified cookie path
    #
    # @param [String,URI] request URI yielding this cookie
    # @param [String] path on cookie
    def self.determine_cookie_path(request_uri, cookie_path)
      uri = to_uri request_uri
      cookie_path = to_path cookie_path

      if cookie_path.nil? || cookie_path.empty?
        cookie_path = cookie_base_path uri.path
      end
      cookie_path
    end

    # Given a URI, compute the relevant search domains for pre-existing
    # cookies. This includes all the valid dotted forms for a named or IP
    # domains.
    #
    # @param [String, URI] request_uri requested uri
    # @return [Array<String>] all cookie domain values which would match the
    #   requested uri
    def self.compute_search_domains(request_uri)
      uri = to_uri request_uri
      return nil unless uri.is_a? URI::HTTP
      host = uri.host
      compute_search_domains_for_host host
    end

    # Given a host, compute the relevant search domains for pre-existing
    # cookies
    #
    # @param [String] host host being requested
    # @return [Array<String>] all cookie domain values which would match the
    #   requested uri
    def self.compute_search_domains_for_host(host)
      host = effective_host host
      result = [host]
      unless host =~ IPADDR
        result << ".#{host}"
        base = hostname_reach host
        result << ".#{base}" if base
      end
      result
    end

    # Processes cookie domain data using the following rules:
    # Domains strings of the form .foo.com match 'foo.com' and all immediate
    # subdomains of 'foo.com'. Domain strings specified of the form 'foo.com'
    # are modified to '.foo.com', and as such will still apply to subdomains.
    #
    # Cookies without an explicit domain will have their domain value taken
    # directly from the URL, and will _NOT_ have any leading dot applied. For
    # example, a request to http://foo.com/ will cause an entry for 'foo.com'
    # to be created - which applies to foo.com but no subdomain.
    #
    # Note that this will not attempt to detect a mismatch of the request uri
    # domain and explicitly specified cookie domain
    #
    # @param [String, URI] request_uri originally requested URI
    # @param [String] cookie domain value
    # @return [String] effective host
    def self.determine_cookie_domain(request_uri, cookie_domain)
      uri = to_uri request_uri
      domain = to_domain cookie_domain

      return effective_host(uri.host) if domain.nil? || domain.empty?
      domain = domain.downcase
      if domain =~ IPADDR || domain.start_with?('.')
        domain
      else
        ".#{domain}"
      end
    end

    # Compute the effective host (RFC 2965, section 1)
    #
    # Has the added additional logic of searching for interior dots
    # specifically, and matches colons to prevent .local being suffixed on
    # IPv6 addresses
    #
    # @param [String, URI] host_or_uridomain name, or absolute URI
    # @return [String] effective host per RFC rules
    def self.effective_host(host_or_uri)
      hostname = to_domain host_or_uri
      hostname = hostname.downcase

      if /.[\.:]./.match(hostname) || hostname == '.local'
        hostname
      else
        hostname + '.local'
      end
    end

    # Check whether a cookie meets all of the rules to be created, based on
    # its internal settings and the URI it came from.
    #
    # @param [String,URI] request_uri originally requested URI
    # @param [Cookie] cookie object
    # @param [true] will always return true on success
    # @raise [InvalidCookieError] on failures, containing all validation errors
    def self.validate_cookie(request_uri, cookie)
      uri = to_uri request_uri
      request_path = uri.path
      cookie_host = cookie.domain
      cookie_path = cookie.path

      errors = []

      # From RFC 2965, Section 3.3.2 Rejecting Cookies

      # A user agent rejects (SHALL NOT store its information) if the
      # Version attribute is missing. Note that the legacy Set-Cookie
      # directive will result in an implicit version 0.
      errors << 'Version missing' unless cookie.version

      # The value for the Path attribute is not a prefix of the request-URI

      # If the initial request path is empty then this will always fail
      # so check if it is empty and if so then set it to /
      request_path = '/' if request_path == ''

      unless request_path.start_with? cookie_path
        errors << 'Path is not a prefix of the request uri path'
      end

      unless cookie_host =~ IPADDR || # is an IPv4 or IPv6 address
             cookie_host =~ /.\../ || # contains an embedded dot
             cookie_host == '.local' # is the domain cookie for local addresses
        errors << 'Domain format is illegal'
      end

      # The effective host name that derives from the request-host does
      # not domain-match the Domain attribute.
      #
      # The request-host is a HDN (not IP address) and has the form HD,
      # where D is the value of the Domain attribute, and H is a string
      # that contains one or more dots.
      unless domains_match cookie_host, uri
        errors << 'Domain is inappropriate based on request URI hostname'
      end

      # The Port attribute has a "port-list", and the request-port was
      # not in the list.
      unless cookie.ports.nil? || !cookie.ports.empty?
        unless cookie.ports.find_index uri.port
          errors << 'Ports list does not contain request URI port'
        end
      end

      fail InvalidCookieError, errors unless errors.empty?

      # Note: 'secure' is not explicitly defined as an SSL channel, and no
      # test is defined around validity and the 'secure' attribute
      true
    end

    # Break apart a traditional (non RFC 2965) cookie value into its core
    # components. This does not do any validation, or defaulting of values
    # based on requested URI
    #
    # @param [String] set_cookie_value a Set-Cookie header formatted cookie
    #   definition
    # @return [Hash] Contains the parsed values of the cookie
    def self.parse_set_cookie(set_cookie_value)
      args = {}
      params = set_cookie_value.split(/;\s*/)

      first = true
      params.each do |param|
        result = PARAM1.match param
        unless result
          fail InvalidCookieError,
               "Invalid cookie parameter in cookie '#{set_cookie_value}'"
        end
        key = result[1].downcase.to_sym
        keyvalue = result[2]
        if first
          args[:name] = result[1]
          args[:value] = keyvalue
          first = false
        else
          case key
          when :expires
            begin
              args[:expires_at] = Time.parse keyvalue
            rescue ArgumentError
              raise unless $ERROR_INFO.message == 'time out of range'
              args[:expires_at] = Time.at(0x7FFFFFFF)
            end
          when :"max-age"
            args[:max_age] = keyvalue.to_i
          when :domain, :path
            args[key] = keyvalue
          when :secure
            args[:secure] = true
          when :httponly
            args[:http_only] = true
          when :samesite
            args[:samesite] = keyvalue.downcase
          else
            fail InvalidCookieError, "Unknown cookie parameter '#{key}'"
          end
        end
      end
      args[:version] = 0
      args
    end

    # Parse a RFC 2965 value and convert to a literal string
    def self.value_to_string(value)
      if /\A"(.*)"\Z/ =~ value
        value = Regexp.last_match(1)
        value.gsub(/\\(.)/, '\1')
      else
        value
      end
    end

    # Attempt to decipher a partially decoded version of text cookie values
    def self.decode_value(value)
      if /\A"(.*)"\Z/ =~ value
        value_to_string value
      else
        CGI.unescape value
      end
    end

    # Break apart a RFC 2965 cookie value into its core components.
    # This does not do any validation, or defaulting of values
    # based on requested URI
    #
    # @param [String] set_cookie_value a Set-Cookie2 header formatted cookie
    #   definition
    # @return [Hash] Contains the parsed values of the cookie
    def self.parse_set_cookie2(set_cookie_value)
      args = {}
      first = true
      index = 0
      begin
        md = PARAM2.match set_cookie_value[index..-1]
        if md.nil? || md.offset(0).first != 0
          fail InvalidCookieError,
               "Invalid Set-Cookie2 header '#{set_cookie_value}'"
        end
        index += md.offset(0)[1]

        key = md[1].downcase.to_sym
        keyvalue = md[2] || md[3]
        if first
          args[:name] = md[1]
          args[:value] = keyvalue
          first = false
        else
          keyvalue = value_to_string keyvalue
          case key
          when :comment, :commenturl, :domain, :path
            args[key] = keyvalue
          when :discard, :secure
            args[key] = true
          when :httponly
            args[:http_only] = true
          when :"max-age"
            args[:max_age] = keyvalue.to_i
          when :version
            args[:version] = keyvalue.to_i
          when :port
            # must be in format '"port,port"'
            ports = keyvalue.split(/,\s*/)
            args[:ports] = ports.map(&:to_i)
          else
            fail InvalidCookieError, "Unknown cookie parameter '#{key}'"
          end
        end
      end until md.post_match.empty?
      # if our last match in the scan failed
      if args[:version] != 1
        fail InvalidCookieError,
             'Set-Cookie2 declares a non RFC2965 version cookie'
      end

      args
    end
  end
end
