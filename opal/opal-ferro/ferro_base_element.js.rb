module Ferro
  # This class encapsulates all functionality of
  # Master Object Model elements.
  # Every Ferro element should (indirectly) inherit from this class.
  # Ferro elements should not be instanciated directly. Instead the parent
  # element should call the add_child method.
  class BaseElement

    include Elementary
    
    attr_reader :parent, :sym, :children, :element, :domtype

    # Create the element and continue the creation
    # process (casading).
    # Ferro elements should not be instanciated directly. Instead the
    # parent element should call the add_child method.
    #
    # @param [String] parent The parent Ruby element
    # @param [String] sym The symbolized name for the element
    # @param [Hash] options Any options for the creation process
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

    # Searches the element hierarchy upwards until the factory is found
    def factory
      @parent.factory
    end

    # Searches the element hierarchy upwards until the root element is
    # found
    def root
      @parent.root
    end

    # Searches the element hierarchy upwards an element is found that is
    # a component
    def component
      @parent.component
    end

    # Searches the element hierarchy upwards until the router is found
    def router
      @parent.router
    end

    # Delete a key from the elements options hash. Will be renamed
    # to option_delete.
    #
    # @param [key] key Key of the option hash to be removed
    # @param [value] default Optional value to use if option value is nil
    # @return [value] Return the current option value or value of
    #   default parameter
    def option_replace(key, default = nil)
      value = @options[key] || default
      @options.delete(key) if @options.has_key?(key)
      value
    end

    # Add states to the element. A state toggles a CSS class with the
    # same (dasherized) name as the state.
    # If the state is thruthy (not nil or true) the CSS class is added
    # to the element. Otherwise the CSS class is removed.
    #
    # @param [Array] states An array of state names to add to the
    #   element. All disabled (false) state initially.
    def add_states(states)
      states.each do |state|
        add_state(state)
      end
    end

    # Add a state to the element. A state toggles a CSS class with the
    # same (dasherized) name as the state.
    # If the state is thruthy (not nil or true) the CSS class is added
    # to the element. Otherwise the CSS class is removed.
    #
    # @param [String] state The state name to add to the element
    # @param [value] value The initial enabled/disabled state value
    def add_state(state, value = false)
      @states[state] = [
        factory.composite_state(self.class.name, state),
        value
      ]

      classify_state @states[state]
    end

    # Update the value of the state.
    #
    # @param [String] state The state name
    # @param [Boolean] active The new value of the state. Pass
    #   true to enable and set the CSS class
    #   false to disable and remove the CSS class
    #   nil to skip altering state and the CSS class
    def update_state(state, active)
      if !active.nil?
        @states.each do |s, v|
          v[1] = active if s == state
          classify_state v
        end
      end
    end

    # Toggle the boolean value of the state
    #
    # @param [String] state The state name
    def toggle_state(state)
      @states.select { |s, _| s == state }.each do |s, v|
        v[1] = !v[1]
        classify_state v
      end
    end

    # Add or remove the CSS class for the state
    #
    # @param [String] state The state name
    def classify_state(state)
      if state[1]
        state[0].each do |name|
          `#{element}.classList.add(#{name})`
        end
      else
        state[0].each do |name|
          `#{element}.classList.remove(#{name})`
        end
      end
    end

    # Determine if the state is active
    #
    # @param [String] state The state name
    # @return [Boolean] The state value
    def state_active?(state)
      @states[state][1]
    end

    # Get the current html value of the element
    #
    # @return [String] The html value
    def value
      `#{@element}.innerHTML`
    end

    # Get the current text content of the element
    #
    # @return [String] The text value
    def get_text
      `#{@element}.textContent`
    end

    # Set the current text content of the element
    #
    # @param [String] value The new text value
    def set_text(value)
      # https://developer.mozilla.org/en-US/docs/Web/API/Node/textContent
      `#{@element}.textContent = #{value}`
    end

    # Set the current html content of the element. Use with caution if
    # the html content is not trusted, it may be invalid or contain scripts.
    #
    # @param [String] raw_html The new html value
    def html(raw_html)
      `#{@element}.innerHTML = #{raw_html}`
    end

    # Set an attribute value on the elements corresponding DOM element
    #
    # @param [String] name The attribute name
    # @param [String] value The attribute value
    def set_attribute(name, value)
      if name == 'scrollTop'
        `#{element}.scrollTop=#{value}`
      else
        `#{element}.setAttribute(#{name}, #{value})`
      end
    end

    # Remove an attribute value on the elements corresponding DOM element
    #
    # @param [String] name The attribute name
    def remove_attribute(name)
      `#{element}.removeAttribute(#{name})`
    end
  end
end