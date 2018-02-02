module FerroElementary

  RESERVED_NAMES = %i[
    initialize factory root router page404
    creation _before_create before_create create _after_create
    after_create style _stylize cascade
    add_child forget_children remove_child method_missing destroy
    value set_text html parent children element domtype options
    add_states add_state update_state toggle_state state_active
  ]

  def creation
    _before_create
    before_create
    create
    _after_create
    after_create
    _stylize
    cascade
  end
  
  def _before_create;end
  def before_create;end

  def create
    @element = factory.create_element(self, @domtype, @parent, @options) if @domtype 
  end

  def _after_create;end
  def after_create;end

  def style;end

  def _stylize
    styles = style

    if styles.class == Hash
      set_attribute(
        'style',
        styles.map { |k, v| "#{k}:#{v};" }.join
      )
    end
  end

  def cascade;end

  def add_child(name, element_class, options = {})
    sym = symbolize(name)
    raise "Child '#{sym}' already defined" if @children.has_key?(sym)
    raise "Illegal name (#{sym})" if RESERVED_NAMES.include?(sym)
    @children[sym] = element_class.new(self, sym, options)
  end

  def symbolize(name)
    name.downcase.to_sym
  end

  def forget_children
    children = {}
  end

  def remove_child(sym)
    @children.delete(sym)
  end

  def destroy
    `#{parent.element}.removeChild(#{element})`
    parent.remove_child(@sym)
  end

  # Getter for children
  def method_missing(method_name, *args, &block)
    if @children.has_key?(method_name)
      @children[method_name]
    else
      super
    end
  end
end