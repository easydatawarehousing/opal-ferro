module Ferro
  # Create DOM elements.
  class Factory

    attr_reader :body

    # Creates the factory. Do not create a factory directly, instead
    # call the 'factory' method that is available in all Ferro classes
    def initialize
      @body = `document.body`
      `while (document.body.firstChild) {document.body.removeChild(document.body.firstChild);}`
    end

    # Create a DOM element.
    #
    # @param [String] target The Ruby class instance
    # @param [String] type Type op DOM element to create
    # @param [String] parent The Ruby parent element
    # @param [Hash] options Options to pass to the element.
    #   See FerroElementary::add_child
    # @return [String] the DOM element
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
      if target.class.superclass != BaseElement
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

    # Convert a Ruby classname to a dasherized name for use with CSS.
    #
    # @param [String] class_name The Ruby class name
    # @return [String] CSS class name
    def dasherize(class_name)
      return class_name if class_name !~ /[A-Z:_]/
      c = class_name.to_s.gsub('::', '')

      (c[0] + c[1..-1].gsub(/[A-Z]/){ |c| "-#{c}" }).
        downcase.
        gsub('_', '-')
    end

    # Convert a CSS classname to a camelized Ruby class name.
    #
    # @param [String] class_name CSS class name
    # @return [String] A Ruby class name
    def camelize(class_name)
      return class_name if class_name !~ /-/
      class_name.gsub(/(?:-|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }.strip
    end
  end
end