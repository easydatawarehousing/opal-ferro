module Ferro

  # This module contains all 'inline' elements.
  module Element
    # Creates a block element. Alias for BaseElement.
    # In the DOM creates a: <div>.
    class Block < BaseElement
    end

    # Creates an inline text element.
    # In the DOM creates a: <p> or <h1> .. <h6> depending on
    # option :size. Set to 1..6 to create <h.> elements.
    # Leave option blank or use 0 to create <p> elements.
    class Text < BaseElement

      # Internal method.
      def _before_create
        @size    = option_replace :size, 0
        @domtype = @size == 0 ? :p : "h#{@size}"
      end
    end

    # Creates an inline element.
    # In the DOM creates a: <ol> or <ul> depending on
    # option :type. Set to '1', 'A', 'a', 'I' or 'i' to create <ol>
    # elements. Leave option blank to create <ul> elements.
    class List < BaseElement

      # Internal method.
      def _before_create
        @domtype = @options.has_key?(:type) ? :ol : :ul
        @items   = []
        @id      = Sequence.new 'list_'
      end

      # Add an item to the (un)ordered list.
      #
      # @param [String] element_class Ruby classname for the new element
      # @param [Hash] options Any options for the new element
      def add_item(element_class, options = {})
        @items << add_child(@id.next, element_class, options).sym
      end

      # The number of items in the list.
      #
      # @return [Integer] Returns the number of items in the list
      def item_count
        @items.length
      end

      # The first item in the list.
      #
      # @return [element] Returns first element in the list
      def first_item
        @children[@items.first]
      end

      # The last item in the list.
      #
      # @return [element] Returns last element in the list
      def last_item
        @children[@items.last]
      end

      # Remove an item from the (un)ordered list.
      #
      # @param [Symbol] sym The symbol of the item to be removed
      def unlist_item(sym)
        @items.delete_if { |item| item == sym }
      end
    end

    # Creates an inline element.
    # In the DOM creates a: <li>.
    # To be used together with {ElementList}.
    class ListItem < BaseElement

      # Internal method.
      def _before_create
        @domtype = :li
      end

      # Remove this item from the list and the DOM.
      def destroy
        super
        parent.unlist_item(@sym)
      end
    end

    # Creates an inline element.
    # In the DOM creates a: <a>.
    # When link is clicked will navigate to the new location within the
    # application or page 404 if not found.
    # Specify option :href to set the location.
    class Anchor < BaseElement

      # Internal method.
      def _before_create
        @domtype = :a
        @href = @options[:href]
      end

      # Internal method.
      def _after_create
        `#{@element}.addEventListener("click",function(e){e.preventDefault();history.pushState(null,null,#{@href});#{clicked};document.activeElement.blur();})`
      end

      # Set a new html reference for this item.
      #
      # @param [String] value New reference
      def update_href(value)
        @href = value
        set_attribute('href', @href)
      end

      # Callback for click event. Calls `router.navigated`.
      # Override this method to change its behavior.
      def clicked
        router.navigated
      end
    end

    # Creates an inline element.
    # In the DOM creates a: <a>.
    # When link is clicked will navigate to a location outside the
    # application and in a new tab.
    # Specify option :target to set the location.
    class ExternalLink < BaseElement

      # Internal method.
      def _before_create
        @domtype = :a
        @options[:target] ||= '_blank'
      end
    end
  end
end