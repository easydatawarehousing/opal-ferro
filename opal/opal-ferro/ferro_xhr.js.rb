module Ferro
  require 'json'
  require 'native'

  # Create and execute AJAX requests.
  # Based on turbolinks/http_request.
  # Specify the url for the request and two callbacks,
  # one for succesful completion of the request and one
  # for a failed request.
  #
  # It is safe to destroy the FerroXhr instance after
  # one of it's callbacks have completed.
  # Note that there are no private methods in Opal. Methods that
  # should be private are marked in the docs with 'Internal method'.
  #
  # This class can only send and receive JSON.
  # For non-get requests a csrf token can be specified or left
  # blank. When blank this class will try to find the token in
  # the header meta data.
  class Xhr

    # Error message for timeouts.
    TIMEOUT_FAILURE = 'Timeout'

    # Start AJAX request.
    #
    # Valid options are:
    # * :timeout (Integer) Request-timout
    # * :accept (String) Header-Accept
    # * :method (Symbol) Html method, default: :get
    # * :csrf (String) Csrf token, if blank and method is not :get,
    #   meta tag 'csrf-token' will be used
    # * :body (Hash) Hash of parameters to be sent
    #
    # @param [String] url The url for the request
    # @param [Method] callback Success callback method. The callback
    #        method should accept one parameter [Hash] containing the
    #        parsed json object returned by the AJAX call
    # @param [Method] error_callback Failure callback method. The callback
    #        method should accept two parameters [Integer, String]
    #        containing the status and error message
    # @param [Hash] options See valid options
    def initialize(url, callback, error_callback, options = {})
      @url            = url
      @callback       = callback
      @error_callback = error_callback
      @timeout        = options[:timeout]  || 5000
      @accept         = options[:accept]   || 'application/json'
      @method         = (options[:method] || :get).upcase
      @csrf           = options[:csrf]
      @body           = options[:body] ? options[:body].to_json.to_s : nil
      @xhr            = nil
      @sent           = false

      createXHR
      send
    end

    # Internal method to start the AJAX request.
    def send
      if @xhr && !@sent
        @xhr.JS.send(@body)
        @sent = true
      end
    end

    # Cancel a running AJAX request.
    def cancel
      @xhr.JS.abort if @xhr && @sent
    end

    # Internal method to set up the AJAX request.
    def createXHR
      @xhr = `new XMLHttpRequest`

      `#{@xhr}.open(#{@method}, #{@url}, true)`
      `#{@xhr}.timeout = #{@timeout}`
      `#{@xhr}.setRequestHeader('Accept', #{@accept})`
      `#{@xhr}.setRequestHeader('X-Requested-With', 'XMLHttpRequest')`

      if @method != 'GET'
        `#{@xhr}.setRequestHeader('X-CSRF-Token', #{csrf_token})`
        if @body
          `#{@xhr}.setRequestHeader('Content-Type', #{@accept})`
          `#{@xhr}.setRequestHeader('Content-Length', #{@body.length})`
        end
      end

      `#{@xhr}.addEventListener('load',    function(){#{requestLoaded}})`
      `#{@xhr}.addEventListener('error',   function(){#{requestFailed}})`
      `#{@xhr}.addEventListener('timeout', function(){#{requestTimedOut}})`
      `#{@xhr}.addEventListener('abort',   function(){#{requestCanceled}})`
      nil
    end

    # Internal method to get the csrf token from header meta data.
    def csrf_token
      return @csrf if @csrf
      token = Native(`document.getElementsByName('csrf-token')`)
      @csrf = token[0].content if token.length > 0
    end

    # Internal method to clean up the AJAX request.
    def destroy
      `#{@xhr} = null`
    end

    # Internal callback method, will call the success callback specified
    # in initialize or the failure callback if the html return status is
    # 300 or higher.
    def requestLoaded
      begin
        status = Native(`#{@xhr}.status`)
        raise if status >= 300
        json = JSON.parse(`#{@xhr}.response`)
        @callback.call(json)
      rescue => error
        @failed = true
        @error_callback.call(status, error)
      end

      destroy
    end

    # Internal callback method, will call the failure callback specified
    # in initialize.
    def requestFailed
      @failed = true
      @error_callback.call(`#{@xhr}.status`, Native(`#{@xhr}.response`))
      destroy
    end

    # Internal callback method, will call the failure callback specified
    # in initialize.
    def requestTimedOut
      @failed = true
      @error_callback.call(0, TIMEOUT_FAILURE)
      destroy
    end

    # Internal callback method.
    def requestCanceled
      destroy
    end
  end
end