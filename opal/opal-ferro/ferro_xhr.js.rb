require 'json'
require 'native'

# Create and execute AJAX get requests.
# Based on turbolinks/http_request.
# Specify the url for the request and two callbacks,
# one for succesful completion of the request and one
# for a failed request.
#
# It is safe to destroy the FerroXhr instance after
# one of it's callbacks have completed.
# Note that there are no private methods in Opal. Methods that
# should be private are marked in the docs with 'Internal method'.
class FerroXhr

  NETWORK_FAILURE = 'Network error'
  TIMEOUT_FAILURE = 'Timeout'

  # Start AJAX request.
  #
  # @param [String] url The url for the request
  # @param [Method] callback Success callback method. The callback
  #        method should accept one parameter [Hash] containing the
  #        parsed json object returned by the AJAX call
  # @param [Method] error_callback Failure callback method. The callback
  #        method should accept two parameters [Integer, String]
  #        containing the status and error message
  # @param [Hash] options Valid hash keys are:
  #        :referrer (Header-Referrer String),
  #        :timeout (Request-timout Integer),
  #        :accept (Header-Accept String)
  def initialize(url, callback, error_callback, options = {})
    @url            = url
    @callback       = callback
    @error_callback = error_callback
    @referrer       = options[:referrer] || 'Ferro'
    @timeout        = options[:timeout]  || 5000
    @accept         = options[:accept]   || 'application/json'
    @xhr            = nil
    @sent           = false

    createXHR
    send
  end

  # Internal method to start the AJAX request.
  def send
    if @xhr && !@sent
      @xhr.JS.send
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
    `#{@xhr}.open('GET', #{@url}, true)`
    `#{@xhr}.timeout = #{@timeout}`
  # `#{@xhr}.responseType = 'json'` if @accept == 'application/json'
    `#{@xhr}.setRequestHeader('Accept', #{@accept})`
    `#{@xhr}.setRequestHeader('Ferro-Referrer', #{@referrer})`
    `#{@xhr}.addEventListener('load',    function(){#{requestLoaded}})`
    `#{@xhr}.addEventListener('error',   function(){#{requestFailed}})`
    `#{@xhr}.addEventListener('timeout', function(){#{requestTimedOut}})`
    `#{@xhr}.addEventListener('abort',   function(){#{requestCanceled}})`
    nil
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