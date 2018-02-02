class FerroElementComponent < FerroElement
  def component
    self
  end
end

# Semantical elements
class FerroElementHeader < FerroElementComponent
  def _before_create
    @domtype = :header
  end
end

class FerroElementNavigation < FerroElementComponent
  def _before_create
    @domtype = :nav
  end
end

class FerroElementSection < FerroElementComponent
  def _before_create
    @domtype = :section
  end
end

class FerroElementArticle < FerroElementComponent
  def _before_create
    @domtype = :article
  end
end

class FerroElementAside < FerroElementComponent
  def _before_create
    @domtype = :aside
  end
end

class FerroElementFooter < FerroElementComponent
  def _before_create
    @domtype = :footer
  end
end

FerroElementBlock = FerroElement

# Inline elements
class FerroElementText < FerroElement
  def _before_create
    @size    = option_replace :size, 0
    @domtype = @size == 0 ? :p : "h#{@size}"
  end
end

class FerroElementList < FerroElement
  def _before_create
    @domtype = @options.has_key?(:type) ? :ol : :ul
    @items   = []
    @id      = FerroSequence.new 'list_'
  end

  def add_item(element_class, options = {})
    @items << add_child(@id.next, element_class, options).sym
  end

  def item_count
    @items.length
  end

  def first_item
    @children[@items.first]
  end

  def last_item
    @children[@items.last]
  end

  def unlist_item(sym)
    @items.delete_if { |item| item == sym }
  end
end

class FerroElementListItem < FerroElement
  def _before_create
    @domtype = :li
  end

  def destroy
    super
    parent.unlist_item(@sym)
  end
end

class FerroElementAnchor < FerroElement
  def _before_create
    @domtype = :a
    @href = @options[:href]
  end

  def _after_create
    `#{@element}.addEventListener("click",function(e){e.preventDefault();history.pushState(null,null,#{@href});#{clicked};document.activeElement.blur();})`
  end

  def update_href(value)
    @href = value
    set_attribute('href', @href)
  end

  def clicked
    router.navigated
  end
end

class FerroElementExternalLink < FerroElement
  def _before_create
    @domtype = :a
    @options[:target] ||= '_blank'
  end
end

# Miscellaneous elements
class FerroElementImage < FerroElement

  # Todo use:
  # <figure>
  # <figcaption>
  
  def _before_create
    @domtype = :img
    @options[:alt] ||= @options[:src]
  end
end

class FerroElementCanvas < FerroElement
  def _before_create
    @domtype = :canvas
  end
end

class FerroElementScript < FerroElement
  def _before_create
    @domtype = :script
    @run     = option_replace :invoke, true
  end

  def _after_create
    load
    invoke if @run
  end

  def load;end
  def invoke;end
end

class FerroElementVar < FerroElement
  def _before_create
    @domtype = option_replace :domtype, :div
  end
end