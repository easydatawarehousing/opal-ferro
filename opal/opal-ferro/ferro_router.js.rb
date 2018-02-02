require 'native'

class FerroRouter
  
  def initialize(page404)
    @routes  = []
    @page404 = page404
    setup_navigation_listener
  end

  def add_route(path, callback)
    @routes << { parts: path_to_parts(path), callback: callback }
  end

  def setup_navigation_listener
    `window.onpopstate = function(e){#{navigated}}`
  end

  def replace_state(url)
    `history.replaceState(null,null,#{url})`
  end

  def push_state(url)
    `history.pushState(null,null,#{url})`
  end

  def go_to(url)
    push_state(url)
    navigated
  end

  def go_back
    `history.back()`
  end

  def get_location
    Native(`new URL(window.location.href)`)
  end

  def path_to_parts(path)
    path.
      downcase.
      split('/').
      map { |part| part.empty? ? nil : part.strip }.
      compact
  end

  def decode(value)
    `decodeURI(#{value})`
  end

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

  def get_matches(path)
    matches = []

    @routes.each_with_index do |route, i|
      score, pars = score_route(route[:parts], path)
      matches << [i, score, pars] if score > 0
    end

    matches
  end

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