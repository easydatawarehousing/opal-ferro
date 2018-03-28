module Ferro

  require 'native'

  # Wrapper for the web browsers history API.
  # Note that there are no private methods in Opal. Methods that
  # should be private are marked in the docs with 'Internal method'.
  class Router
    
    # Create the router. Do not create a router directly, instead
    # call the 'router' method that is available in all Ferro classes
    # That method points to the router instance that is attached to
    # the FerroDocument.
    #
    # @param [Method] page404 Method that is called when the web browser
    #                 navigates and no route can be found. Override the
    #                 page404 method in FerroDocument.
    def initialize(page404)
      @routes  = []
      @page404 = page404
      setup_navigation_listener
    end

    # Add a new route to the router.
    #
    # Examples: when the following routes are created and the web browser
    # navigates to a url matching the route, the callback method will be
    # called with parameters:
    #   add_route('/ferro/page1', my_cb) # '/ferro/page1'  => my_cb({})
    #   add_route('/user/:id',    my_cb) # '/user/1'       => my_cb({id: 1})
    #   add_route('/ferro',       my_cb) # '/ferro?page=1' => my_cb({page: 1})
    #
    # @param [String] path Relative url (without protocol and host)
    # @param [Method] callback Method that is called when the web browser
    #                 navigates and the path is matched. The callback
    #                 method should accept one parameter [Hash]
    #                 containing the parameters found in the matched url
    def add_route(path, callback)
      @routes << { parts: path_to_parts(path), callback: callback }
    end

    # Internal method to set 'onpopstate'
    def setup_navigation_listener
      `window.onpopstate = function(e){#{navigated}}`
    end

    # Replace the current location in the web browsers history
    #
    # @param [String] url Relative url (without protocol and host)
    def replace_state(url)
      `history.replaceState(null,null,#{url})`
    end

    # Add a location to the web browsers history
    #
    # @param [String] url Relative url (without protocol and host)
    def push_state(url)
      `history.pushState(null,null,#{url})`
    end

    # Navigate to url
    #
    # @param [String] url Relative url (without protocol and host)
    def go_to(url)
      push_state(url)
      navigated
    end

    # Navigate back
    def go_back
      `history.back()`
    end

    # Internal method to get the new location
    def get_location
      Native(`new URL(window.location.href)`)
    end

    # Internal method to split a path into components
    def path_to_parts(path)
      path.
        downcase.
        split('/').
        map { |part| part.empty? ? nil : part.strip }.
        compact
    end

    # URI decode a value
    #
    # @param [String] value Value to decode
    def decode(value)
      `decodeURI(#{value})`
    end

    # Internal method called when the web browser navigates
    def navigated
      url = get_location
      @params = []

      idx = match(path_to_parts(decode(url.pathname)), decode(url.search))

      if idx
        @routes[idx][:callback].call(@params)
      else
        @page404.call(url.pathname)
      end
    end

    # Internal method to match a path to the most likely route
    #
    # @param [String] path Url to match
    # @param [String] search Url search parameters
    def match(path, search)
      matches = get_matches(path)

      if matches.length > 0
        match = matches.sort { |m| m[1] }.first

        @params = match[2]
        add_search_to_params(search)

        match[0]
      else
        nil
      end
    end

    # Internal method to match a path to possible routes
    #
    # @param [String] path Url to match
    def get_matches(path)
      matches = []

      @routes.each_with_index do |route, i|
        score, pars = score_route(route[:parts], path)
        matches << [i, score, pars] if score > 0
      end

      matches
    end

    # Internal method to add a match score
    #
    # @param [String] parts Parts of a route
    # @param [String] path Url to match
    def score_route(parts, path)
      score = 0
      pars  = {}

      if parts.length == path.length
        parts.each_with_index do |part, i|
          if part[0] == ':'
            score += 1
            pars["#{part[1..-1]}"] = path[i]
          elsif part == path[i].downcase
            score += 2
          end
        end
      end

      return score, pars
    end

    # Internal method to split search parameters
    #
    # @param [String] search Url search parameters
    def add_search_to_params(search)
      if !search.empty?
        pars = search[1..-1].split('&')

        pars.each do |par|
          pair = par.split('=')
          @params[ pair[0] ] = pair[1] if pair.length == 2
        end
      end
    end
  end
end