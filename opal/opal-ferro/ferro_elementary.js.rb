module Ferro
  # Module defines element creation methods and child management.
  # Note that there are no private methods in Opal. Methods that
  # should be private are marked in the docs with 'Internal method'.
  module Elementary

    # Array of reseved names, child element should not have a name
    # that is included in this list
    RESERVED_NAMES = %i[
      initialize factory root router page404
      creation _before_create before_create create _after_create
      after_create style _stylize cascade
      add_child forget_children remove_child method_missing destroy
      value set_text html parent children element domtype options
      add_states add_state update_state toggle_state state_active
    ]

    # Create DOM element and children elements.
    # Calls before- and after create hooks.
    def creation
      _before_create
      before_create
      create
      _after_create
      after_create
      _stylize
      cascade
    end

    # Internal method.
    def _before_create;end

    # Internal method.
    def before_create;end

    # Calls the factory to create the DOM element.
    def create
      @element = factory.create_element(self, @domtype, @parent, @options) if @domtype 
    end

    # Internal method.
    def _after_create;end

    # Internal method.
    def after_create;end

    # Override this method to return a Hash of styles.
    # Hash-key is the CSS style name, hash-value is the CSS style value.
    def style;end

    # Internal method.
    def _stylize
      styles = style

      if styles.class == Hash
        set_attribute(
          'style',
          styles.map { |k, v| "#{k}:#{v};" }.join
        )
      end
    end

    # Override this method to continue the MOM creation process.
    def cascade;end

    # Add a child element.
    #
    # @param [String] name A unique name for the element that is not
    #   in RESERVED_NAMES
    # @param [String] element_class Ruby class name for the new element
    # @param [Hash] options Options to pass to the element. Any option key
    #   that is not recognized is set as an attribute on the DOM element.
    #   Recognized keys are:
    #     prepend Prepend the new element before this DOM element
    #     content Add the value of content as a textnode to the DOM element
    def add_child(name, element_class, options = {})
      sym = symbolize(name)
      raise "Child '#{sym}' already defined" if @children.has_key?(sym)
      raise "Illegal name (#{sym})" if RESERVED_NAMES.include?(sym)
      @children[sym] = element_class.new(self, sym, options)
    end

    # Convert a string containing a variable name to a symbol.
    def symbolize(name)
      name.downcase.to_sym
    end

    # Remove all child elements.
    def forget_children
      children = {}
    end

    # Remove a specific child element.
    #
    # param [Symbol] sym The element to remove
    def remove_child(sym)
      @children.delete(sym)
    end

    # Recursively iterate all child elements
    #
    # param [Block] block A block to execute for every child element
    #                     and the element itself
    def each_child(&block)
      if block_given?
        block.call self

        @children.each do |_, child|
          child.each_child(&block)
        end
      end
    end

    # Remove a DOM element.
    def destroy
      `#{parent.element}.removeChild(#{element})`
      parent.remove_child(@sym)
    end

    # Getter for children.
    def method_missing(method_name, *args, &block)
      if @children.has_key?(method_name)
        @children[method_name]
      else
        super
      end
    end
  end
end