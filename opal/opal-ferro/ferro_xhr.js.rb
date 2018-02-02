# Based on turbolinks/http_request
require 'json'
require 'native'

class FerroXhr

  NETWORK_FAILURE = 'Network error'
  TIMEOUT_FAILURE = 'Timeout'

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

  def send
    if @xhr && !@sent
      @xhr.JS.send
      @sent = true
    end
  end

  def cancel
    @xhr.JS.abort if @xhr && @sent
  end

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

  def destroy
    `#{@xhr} = null`
  end

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

  def requestFailed
    @failed = true
    @error_callback.call(`#{@xhr}.status`, Native(`#{@xhr}.response`))
    destroy
  end

  def requestTimedOut
    @failed = true
    @error_callback.call(0, TIMEOUT_FAILURE)
    destroy
  end

  def requestCanceled
    destroy
  end
end