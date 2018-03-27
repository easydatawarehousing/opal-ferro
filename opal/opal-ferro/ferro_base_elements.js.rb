# TODO Split components into separate file ferro_components

# A generic component element. Will be renamed.
# In the DOM creates a: <div>.
# All semantical elements inherit from this class.
class FerroElementComponent < FerroElement

  # Return self when called by children / descendants.
  def component
    self
  end
end

# Creates a semantical element.
# This is a component. Will be renamed.
# In the DOM creates a: <header>.
class FerroElementHeader < FerroElementComponent

  # Internal method.
  def _before_create
    @domtype = :header
  end
end

# Creates a semantical element.
# This is a component. Will be renamed.
# In the DOM creates a: <nav>.
class FerroElementNavigation < FerroElementComponent

  # Internal method.
  def _before_create
    @domtype = :nav
  end
end

# Creates a semantical element.
# This is a component. Will be renamed.
# In the DOM creates a: <section>.
class FerroElementSection < FerroElementComponent

  # Internal method.
  def _before_create
    @domtype = :section
  end
end

# Creates a semantical element.
# This is a component. Will be renamed.
# In the DOM creates a: <article>.
class FerroElementArticle < FerroElementComponent

  # Internal method.
  def _before_create
    @domtype = :article
  end
end

# Creates a semantical element.
# This is a component. Will be renamed.
# In the DOM creates a: <aside>.
class FerroElementAside < FerroElementComponent

  # Internal method.
  def _before_create
    @domtype = :aside
  end
end

# Creates a semantical element.
# This is a component. Will be renamed.
# In the DOM creates a: <footer>.
class FerroElementFooter < FerroElementComponent

  # Internal method.
  def _before_create
    @domtype = :footer
  end
end

# Creates a block element.
# In the DOM creates a: <div>.
FerroElementBlock = FerroElement

# Creates an inline text element.
# In the DOM creates a: <p> or <h1> .. <h6> depending on
# option :size. Set to 1..6 to create <h.> elements.
# Leave option blank or use 0 to create <p> elements.
class FerroElementText < FerroElement

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
class FerroElementList < FerroElement

  # Internal method.
  def _before_create
    @domtype = @options.has_key?(:type) ? :ol : :ul
    @items   = []
    @id      = FerroSequence.new 'list_'
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
# To be used together with {FerroElementList}.
class FerroElementListItem < FerroElement

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
class FerroElementAnchor < FerroElement

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
class FerroElementExternalLink < FerroElement

  # Internal method.
  def _before_create
    @domtype = :a
    @options[:target] ||= '_blank'
  end
end

# Creates a miscellaneous element.
# In the DOM creates a: <img>.
# Will be changed to use <figure> and <figcaption>
# Specify option :src to set the source url.
class FerroElementImage < FerroElement

  # Internal method.
  def _before_create
    @domtype = :img
    @options[:alt] ||= @options[:src]
  end
end

# Creates a miscellaneous element.
# In the DOM creates a: <canvas>.
class FerroElementCanvas < FerroElement

  # Internal method.
  def _before_create
    @domtype = :canvas
  end
end

# Creates a miscellaneous element.
# In the DOM creates a: <script>.
# Specify option :invoke = false to prevent the script
# from being executed.
class FerroElementScript < FerroElement

  # Internal method.
  def _before_create
    @domtype = :script
    @run     = option_replace :invoke, true
  end

  # Internal method.
  def _after_create
    load
    invoke if @run
  end

  # Override method to specify the content of the Javascript.
  def load;end

  # Override method to specify the execution of the script.
  def invoke;end
end

# Creates any kind of element depending on option :domtype.
class FerroElementVar < FerroElement

  # Internal method.
  def _before_create
    @domtype = option_replace :domtype, :div
  end
end