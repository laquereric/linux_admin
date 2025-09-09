module LinuxAdmin
  class Curl
    extend Logging

    CURL_CMD = '/usr/bin/curl'

    # Download a file from URL
    # @param url [String] URL to download from
    # @param options [Hash] Options for the download operation
    # @option options [String] :output Output file path
    # @option options [Boolean] :follow_redirects Follow HTTP redirects
    # @option options [Integer] :timeout Connection timeout in seconds
    # @option options [Hash] :headers HTTP headers to send
    # @option options [String] :user_agent User agent string
    # @option options [Boolean] :insecure Allow insecure SSL connections
    # @option options [String] :username HTTP basic auth username
    # @option options [String] :password HTTP basic auth password
    def self.download(url, options = {})
      raise ArgumentError, "url is required" unless url

      logger.info("#{self.class.name}##{__method__} Downloading from: #{url}")

      params = {}
      params["-L"] = nil if options[:follow_redirects]
      params["-o"] = options[:output] if options[:output]
      params["--connect-timeout"] = options[:timeout] if options[:timeout]
      params["--max-time"] = options[:timeout] if options[:timeout]
      params["-k"] = nil if options[:insecure]
      params["-A"] = options[:user_agent] if options[:user_agent]
      params["-u"] = "#{options[:username]}:#{options[:password]}" if options[:username] && options[:password]

      # Add custom headers
      if options[:headers]
        options[:headers].each do |key, value|
          params["-H"] = "#{key}: #{value}"
        end
      end

      params[nil] = [url]

      Common.run!(CURL_CMD, :params => params)
    end

    # Upload a file to URL
    # @param url [String] URL to upload to
    # @param file [String] File path to upload
    # @param options [Hash] Options for the upload operation
    # @option options [String] :method HTTP method (POST, PUT, PATCH)
    # @option options [Boolean] :follow_redirects Follow HTTP redirects
    # @option options [Integer] :timeout Connection timeout in seconds
    # @option options [Hash] :headers HTTP headers to send
    # @option options [String] :user_agent User agent string
    # @option options [Boolean] :insecure Allow insecure SSL connections
    # @option options [String] :username HTTP basic auth username
    # @option options [String] :password HTTP basic auth password
    def self.upload(url, file, options = {})
      raise ArgumentError, "url is required" unless url
      raise ArgumentError, "file is required" unless file

      logger.info("#{self.class.name}##{__method__} Uploading #{file} to: #{url}")

      params = {}
      params["-L"] = nil if options[:follow_redirects]
      params["--connect-timeout"] = options[:timeout] if options[:timeout]
      params["--max-time"] = options[:timeout] if options[:timeout]
      params["-k"] = nil if options[:insecure]
      params["-A"] = options[:user_agent] if options[:user_agent]
      params["-u"] = "#{options[:username]}:#{options[:password]}" if options[:username] && options[:password]

      # Set HTTP method
      method = options[:method] || "POST"
      params["-X"] = method

      # Add custom headers
      if options[:headers]
        options[:headers].each do |key, value|
          params["-H"] = "#{key}: #{value}"
        end
      end

      # For file uploads, use -T (upload) or -d (data)
      if method.upcase == "POST" && !options[:headers]&.key?("Content-Type")
        params["-T"] = file
      else
        params["-d"] = "@#{file}"
      end

      params[nil] = [url]

      Common.run!(CURL_CMD, :params => params)
    end

    # Make HTTP request
    # @param url [String] URL to request
    # @param options [Hash] Options for the request
    # @option options [String] :method HTTP method (GET, POST, PUT, DELETE, etc.)
    # @option options [String] :data Data to send in request body
    # @option options [Boolean] :follow_redirects Follow HTTP redirects
    # @option options [Integer] :timeout Connection timeout in seconds
    # @option options [Hash] :headers HTTP headers to send
    # @option options [String] :user_agent User agent string
    # @option options [Boolean] :insecure Allow insecure SSL connections
    # @option options [String] :username HTTP basic auth username
    # @option options [String] :password HTTP basic auth password
    # @option options [Boolean] :silent Suppress progress meter
    # @option options [Boolean] :show_headers Include response headers in output
    def self.request(url, options = {})
      raise ArgumentError, "url is required" unless url

      logger.info("#{self.class.name}##{__method__} Making #{options[:method] || 'GET'} request to: #{url}")

      params = {}
      params["-L"] = nil if options[:follow_redirects]
      params["--connect-timeout"] = options[:timeout] if options[:timeout]
      params["--max-time"] = options[:timeout] if options[:timeout]
      params["-k"] = nil if options[:insecure]
      params["-A"] = options[:user_agent] if options[:user_agent]
      params["-u"] = "#{options[:username]}:#{options[:password]}" if options[:username] && options[:password]
      params["-s"] = nil if options[:silent]
      params["-i"] = nil if options[:show_headers]

      # Set HTTP method
      if options[:method]
        params["-X"] = options[:method]
      end

      # Add request data
      if options[:data]
        params["-d"] = options[:data]
      end

      # Add custom headers
      if options[:headers]
        options[:headers].each do |key, value|
          params["-H"] = "#{key}: #{value}"
        end
      end

      params[nil] = [url]

      Common.run!(CURL_CMD, :params => params)
    end

    # Get HTTP response headers only
    # @param url [String] URL to request
    # @param options [Hash] Options for the request
    def self.head(url, options = {})
      options = options.merge(:method => "HEAD", :silent => true)
      request(url, options)
    end

    # Check if URL is accessible
    # @param url [String] URL to check
    # @param options [Hash] Options for the check
    # @return [Boolean] True if URL is accessible (returns 2xx status)
    def self.accessible?(url, options = {})
      options = options.merge(:silent => true, :show_headers => true)
      result = head(url, options)
      
      # Check if response contains a 2xx status code
      result.output.match(/HTTP\/\d\.\d\s+2\d\d/)
    rescue
      false
    end

    # Get HTTP status code
    # @param url [String] URL to check
    # @param options [Hash] Options for the request
    # @return [Integer, nil] HTTP status code or nil if request fails
    def self.status_code(url, options = {})
      options = options.merge(:silent => true, :show_headers => true)
      result = head(url, options)
      
      # Extract status code from response
      if match = result.output.match(/HTTP\/\d\.\d\s+(\d+)/)
        match[1].to_i
      end
    rescue
      nil
    end

    # Check if curl command is available
    # @return [Boolean] True if curl is available
    def self.available?
      Common.cmd?(:curl)
    end
  end
end
