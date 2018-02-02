class FerroDocument

  include FerroElementary

  def initialize
    @children = {}
    creation
    # router.navigated
  end

  def parent
    self
  end

  def element
    @factory.body
  end

  def factory
    @factory ||= FerroFactory.new
  end

  def root
    self
  end

  def component
    self
  end

  def router
    @router ||= FerroRouter.new(method(:page404))
  end

  def page404(pathname);end
end
