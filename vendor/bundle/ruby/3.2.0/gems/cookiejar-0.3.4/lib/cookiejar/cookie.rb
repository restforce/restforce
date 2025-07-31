require 'time'
require 'uri'
require 'cookiejar/cookie_validation'

module CookieJar
  # Cookie is an immutable object which defines the data model of a HTTP Cookie.
  # The data values within the cookie may be different from the
  # values described in the literal cookie declaration.
  # Specifically, the 'domain' and 'path' values may be set to defaults
  # based on the requested resource that resulted in the cookie being set.
  class Cookie
    # [String] The name of the cookie.
    attr_reader :name
    # [String] The value of the cookie, without any attempts at decoding.
    attr_reader :value

    # [String] The domain scope of the cookie. Follows the RFC 2965
    # 'effective host' rules. A 'dot' prefix indicates that it applies both
    # to the non-dotted domain and child domains, while no prefix indicates
    # that only exact matches of the domain are in scope.
    attr_reader :domain

    # [String] The path scope of the cookie. The cookie applies to URI paths
    # that prefix match this value.
    attr_reader :path

    # [Boolean] The secure flag is set to indicate that the cookie should
    # only be sent securely. Nearly all HTTP User Agent implementations assume
    # this to mean that the cookie should only be sent over a
    # SSL/TLS-protected connection
    attr_reader :secure

    # [Boolean] Popular browser extension to mark a cookie as invisible
    # to code running within the browser, such as JavaScript
    attr_reader :http_only

    # [Fixnum] Version indicator, currently either
    # * 0 for netscape cookies
    # * 1 for RFC 2965 cookies
    attr_reader :version
    # [String] RFC 2965 field for indicating comment (or a location)
    # describing the cookie to a usesr agent.
    attr_reader :comment, :comment_url
    # [Boolean] RFC 2965 field for indicating session lifetime for a cookie
    attr_reader :discard
    # [Array<FixNum>, nil] RFC 2965 port scope for the cookie. If not nil,
    # indicates specific ports on the HTTP server which should receive this
    # cookie if contacted.
    attr_reader :ports
    # [Time] Time when this cookie was first evaluated and created.
    attr_reader :created_at

    # Evaluate when this cookie will expire. Uses the original cookie fields
    # for a max age or expires
    #
    # @return [Time, nil] Time of expiry, if this cookie has an expiry set
    def expires_at
      if @expiry.nil? || @expiry.is_a?(Time)
        @expiry
      else
        @created_at + @expiry
      end
    end

    # Indicates whether the cookie is currently considered valid
    #
    # @param [Time] time to compare against, or 'now' if omitted
    # @return [Boolean]
    def expired?(time = Time.now)
      !expires_at.nil? && time > expires_at
    end

    # Indicates whether the cookie will be considered invalid after the end
    # of the current user session
    # @return [Boolean]
    def session?
      @expiry.nil? || @discard
    end

    # Create a cookie based on an absolute URI and the string value of a
    # 'Set-Cookie' header.
    #
    # @param request_uri [String, URI] HTTP/HTTPS absolute URI of request.
    # This is used to fill in domain and port if missing from the cookie,
    # and to perform appropriate validation.
    # @param set_cookie_value [String] HTTP value for the Set-Cookie header.
    # @return [Cookie] created from the header string and request URI
    # @raise [InvalidCookieError] on validation failure(s)
    def self.from_set_cookie(request_uri, set_cookie_value)
      args = CookieJar::CookieValidation.parse_set_cookie set_cookie_value
      args[:domain] = CookieJar::CookieValidation
                      .determine_cookie_domain request_uri, args[:domain]
      args[:path] = CookieJar::CookieValidation
                    .determine_cookie_path request_uri, args[:path]
      cookie = Cookie.new args
      CookieJar::CookieValidation.validate_cookie request_uri, cookie
      cookie
    end

    # Create a cookie based on an absolute URI and the string value of a
    # 'Set-Cookie2' header.
    #
    # @param request_uri [String, URI] HTTP/HTTPS absolute URI of request.
    # This is used to fill in domain and port if missing from the cookie,
    # and to perform appropriate validation.
    # @param set_cookie_value [String] HTTP value for the Set-Cookie2 header.
    # @return [Cookie] created from the header string and request URI
    # @raise [InvalidCookieError] on validation failure(s)
    def self.from_set_cookie2(request_uri, set_cookie_value)
      args = CookieJar::CookieValidation.parse_set_cookie2 set_cookie_value
      args[:domain] = CookieJar::CookieValidation
                      .determine_cookie_domain request_uri, args[:domain]
      args[:path] = CookieJar::CookieValidation
                    .determine_cookie_path request_uri, args[:path]
      cookie = Cookie.new args
      CookieJar::CookieValidation.validate_cookie request_uri, cookie
      cookie
    end

    # Returns cookie in a format appropriate to send to a server.
    #
    # @param [FixNum] 0 version, 0 for Netscape-style cookies, 1 for
    #   RFC2965-style.
    # @param [Boolean] true prefix, for RFC2965, whether to prefix with
    # "$Version=<version>;". Ignored for Netscape-style cookies
    def to_s(ver = 0, prefix = true)
      return "#{name}=#{value}" if ver == 0

      # we do not need to encode path; the only characters required to be
      # quoted must be escaped in URI
      str = prefix ? "$Version=#{version};" : ''
      str << "#{name}=#{value};$Path=\"#{path}\""
      str << ";$Domain=#{domain}" if domain.start_with? '.'
      str << ";$Port=\"#{ports.join ','}\"" if ports
      str
    end

    # Return a hash representation of the cookie.

    def to_hash
      result = {
        name: @name,
        value: @value,
        domain: @domain,
        path: @path,
        created_at: @created_at
      }
      {
        expiry: @expiry,
        secure: (true if @secure),
        http_only: (true if @http_only),
        version: (@version if version != 0),
        comment: @comment,
        comment_url: @comment_url,
        discard: (true if @discard),
        ports: @ports
      }.each do |name, value|
        result[name] = value if value
      end

      result
    end

    # Determine if a cookie should be sent given a request URI along with
    # other options.
    #
    # This currently ignores domain.
    #
    # @param uri [String, URI] the requested page which may need to receive
    # this cookie
    # @param script [Boolean] indicates that cookies with the 'httponly'
    # extension should be ignored
    # @return [Boolean] whether this cookie should be sent to the server
    def should_send?(request_uri, script)
      uri = CookieJar::CookieValidation.to_uri request_uri
      # cookie path must start with the uri, it must not be a secure cookie
      # being sent over http, and it must not be a http_only cookie sent to
      # a script
      path = if uri.path == ''
               '/'
             else
               uri.path
             end
      path_match   = path.start_with? @path
      secure_match = !(@secure && uri.scheme == 'http')
      script_match = !(script && @http_only)
      expiry_match = !expired?
      ports_match = ports.nil? || (ports.include? uri.port)
      path_match && secure_match && script_match && expiry_match && ports_match
    end

    def decoded_value
      CookieJar::CookieValidation.decode_value value
    end

    # Return a JSON 'object' for the various data values. Allows for
    # persistence of the cookie information
    #
    # @param [Array] a options controlling output JSON text
    #   (usually a State and a depth)
    # @return [String] JSON representation of object data
    def to_json(*a)
      to_hash.merge(json_class: self.class.name).to_json(*a)
    end

    # Given a Hash representation of a JSON document, create a local cookie
    # from the included data.
    #
    # @param [Hash] o JSON object of array data
    # @return [Cookie] cookie formed from JSON data
    def self.json_create(o)
      params = o.inject({}) do |hash, (key, value)|
        hash[key.to_sym] = value
        hash
      end
      params[:version] ||= 0
      params[:created_at] = Time.parse params[:created_at]
      if params[:expiry].is_a? String
        params[:expires_at] = Time.parse params[:expiry]
      else
        params[:max_age] = params[:expiry]
      end
      params.delete :expiry

      new params
    end

    # Compute the cookie search domains for a given request URI
    # This will be the effective host of the request uri, along with any
    # possibly matching dot-prefixed domains
    #
    # @param request_uri [String, URI] address being requested
    # @return [Array<String>] String domain matches
    def self.compute_search_domains(request_uri)
      CookieValidation.compute_search_domains request_uri
    end

    protected

    # Call {from_set_cookie} to create a new Cookie instance
    def initialize(args)
      @created_at, @name, @value, @domain, @path, @secure,
      @http_only, @version, @comment, @comment_url, @discard, @ports \
      = args.values_at \
        :created_at, :name, :value, :domain, :path, :secure,
        :http_only, :version, :comment, :comment_url, :discard, :ports

      @created_at ||= Time.now
      @expiry = args[:max_age] || args[:expires_at]
      @secure     ||= false
      @http_only  ||= false
      @discard    ||= false

      @ports = [@ports] if @ports.is_a? Integer
    end
  end
end
