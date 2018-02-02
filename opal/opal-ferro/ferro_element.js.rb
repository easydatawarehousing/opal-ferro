class FerroElement

  include FerroElementary
  
  attr_reader :parent, :sym, :children, :element, :domtype

  def initialize(parent, sym, options = {})
    @parent   = parent
    @sym      = sym
    @children = {}
    @element  = nil
    @domtype  = :div
    @states   = {}
    @options  = options

    creation
  end

  def factory
    @parent.factory
  end

  def root
    @parent.root
  end

  def component
    @parent.component
  end

  def router
    @parent.router
  end

  def option_replace(key, default = nil)
    value = @options[key] || default
    @options.delete(key) if @options.has_key?(key)
    value
  end

  # Store element states: adds/removes css classes
  def add_states(states)
    states.each do |state|
      add_state(state)
    end
  end

  def add_state(state, value = false)
    @states[state] = [factory.dasherize(state), value]
    classify_state @states[state]
  end

  # active: true, false, nil
  def update_state(state, active)
    if !active.nil?
      @states.each do |s, v|
        v[1] = active if s == state
        classify_state v
      end
    end
  end

  def toggle_state(state)
    @states.select { |s, _| s == state }.each do |s, v|
      v[1] = !v[1]
      classify_state v
    end
  end

  def classify_state(state)
    if state[1]
      `#{element}.classList.add(#{state[0]})`
    else
      `#{element}.classList.remove(#{state[0]})`
    end
  end

  def state_active?(state)
    @states[state][1]
  end

  def value
    `#{@element}.innerHTML`
  end

  def get_text
    `#{@element}.textContent`
  end

  def set_text(value)
    # https://developer.mozilla.org/en-US/docs/Web/API/Node/textContent
    `#{@element}.textContent = #{value}`
  end

  def html(raw_html)
    `#{@element}.innerHTML = #{raw_html}`
  end

  def set_attribute(name, value)
    if name == 'scrollTop'
      `#{element}.scrollTop=#{value}`
    else
      `#{element}.setAttribute(#{name}, #{value})`
    end
  end

  def remove_attribute(name)
    `#{element}.removeAttribute(#{name})`
  end
end