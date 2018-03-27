# This is the entry point for any Ferro application.
# It represents the top level object of the
# Master Object Model (MOM).
# There should be only one class that inhertits
# from FerroDocument in an application.
# This class attaches itself to the DOM
# `document.body` object.
class FerroDocument

  include FerroElementary

  # Create the document and start the creation
  # process (casading).
  def initialize
    @children = {}
    creation
  end

  # The document doesn't have a parent so returns itself.
  def parent
    self
  end

  # Returns the DOM element.
  def element
    @factory.body
  end

  # Returns the one and only instance of the factory.
  def factory
    @factory ||= FerroFactory.new
  end

  # The document class is the root element.
  def root
    self
  end

  # The document class is a component.
  def component
    self
  end

  # Returns the one and only instance of the router.
  def router
    @router ||= FerroRouter.new(method(:page404))
  end

  # Callback for the router when no matching routes
  # can be found. Override this method to add custom
  # behavior.
  #
  # @param [String] pathname The route that was not matched
  #                          by the router
  def page404(pathname);end
end