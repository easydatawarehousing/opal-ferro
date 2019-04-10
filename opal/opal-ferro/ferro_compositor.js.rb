module Ferro
  # Composite styling for DOM objects.
  class Compositor

    attr_reader :current_theme

    # Create the style compositor.
    #
    # @param [Symbol] theme Optional styling theme
    def initialize(theme = nil)
      @current_theme = theme
    end

    # Override this method to define a hash containing the mapping
    # of Ruby classnames to an array of css classnames.  
    # To use the same styling on multiple objects: return the name
    # of the object containing the styling as a String
    # (see css_classes_for method).
    #
    # This hash may also contain the mapping for states.
    # A state name is: <Ruby class name>::<state>.
    # For instance 'MenuLink::active'.
    def map
      raise NotImplementedError
    end

    # Map a Ruby classname to an array of css classnames.
    # If the mapping result is a string: recursively lookup
    # the mapping for that string.
    #
    # @param [String] classname Ruby classname
    # @return [Array] A list of CSS class names
    def css_classes_for(classname)
      css_classes_for_map classname, mapping
    end

    # Internal method to get mapping from selected map.
    def css_classes_for_map(classname, mapping)
      css = mapping[classname]
      css.class == String ? css_classes_for_map(css, mapping) : (css || [])
    end

    # Internal method to switch to a new theme.
    def switch_theme(root_element, theme)
      old_map = @mapping
      new_map = map(theme)

      root_element.each_child do |e|
        old_classes = css_classes_for_map e.class.name, old_map
        new_classes = css_classes_for_map e.class.name, new_map
        update_element_css_classes(e, old_classes, new_classes)

        old_classes = css_classes_for_map e.class.superclass.name, old_map
        new_classes = css_classes_for_map e.class.superclass.name, new_map
        update_element_css_classes(e, old_classes, new_classes)
      end

      @mapping = new_map
    end

    # Internal method to add/remove CSS classes for an object.
    def update_element_css_classes(obj, old_classes, new_classes)
      (old_classes - new_classes).each do |name|
        `#{obj.element}.classList.remove(#{name})`
      end

      (new_classes - old_classes).each do |name|
        `#{obj.element}.classList.add(#{name})`
      end
    end

    # Internal method to cache the mapping.
    def mapping
      @mapping ||= map(@current_theme)
    end
  end
end