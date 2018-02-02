class FerroFactory

  attr_reader :body

  def initialize
    @body = `document.body`
    `while (document.body.firstChild) {document.body.removeChild(document.body.firstChild);}`
  end

  def create_element(target, type, parent, options = {})
    # Create element
    element = `document.createElement(#{type})`

    # Add element to DOM
    if options[:prepend]
      `#{parent.element}.insertBefore(#{element}, #{options[:prepend].element})`
    else
      `#{parent.element}.appendChild(#{element})`
    end

    # Add ruby class to the node
    `#{element}.classList.add(#{dasherize(target.class.name)})`

    # Add ruby superclass to the node to allow for more generic styling
    if target.class.superclass != FerroElement
      `#{element}.classList.add(#{dasherize(target.class.superclass.name)})`
    end

    # Set ruby object_id as default element id
    if !options.has_key?(:id)
      `#{element}.id = #{target.object_id}`
    end
        
    # Set attributes
    options.each do |name, value|
      case name
      when :prepend
        nil
      when :content
        `#{element}.appendChild(document.createTextNode(#{value}))`
      else
        `#{element}.setAttribute(#{name}, #{value})`
      end
    end

    element
  end

  def dasherize(class_name)
    return class_name if class_name !~ /[A-Z_]/
    (class_name[0] + class_name[1..-1].gsub(/[A-Z]/){ |c| "-#{c}" }).downcase.gsub('_', '-')
  end

  def camelize(class_name)
    return class_name if class_name !~ /-/
    class_name.gsub(/(?:-|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }.strip
  end
end