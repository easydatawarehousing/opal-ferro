# Creates a form container.
# In the DOM creates a: <div>.
# A <div> is used instead of a <form> DOM element,
# so we don't have to prevent default actions.
# Will be changed to derive from {FerroElementComponent}.
class FerroForm < FerroElement

  # Internal method.
  def _before_create
    @domtype  = :div
  end
end

# Creates an input element.
# In the DOM creates a: <input type="?">.
# Specify option :type to set the location.
# Use one of these values:
# :text, :password, :reset, :radio, :checkbox, :color,
# :date, :datetime-local, :email, :month, :number,
# :range, :search, :tel, :time, :url, :week.
# Or leave blank to create a :text input.
class FerroFormInput < FerroElement

  # Internal method.
  def _before_create
    @domtype = :input
    @options[:type] ||= :text
    @options[:value] = option_replace :content
    @disabled = option_replace :disabled, false
  end

  # Setter method for input value.
  def value
    `#{@element}.value`
  end

  # Getter method for input value.
  def value=(value)
    `#{@element}.value = #{value}`
  end

  # Set input focus to this element.
  # TODO: Find out why this doesn't seem to work.
  def set_focus
    `#{element}.focus()`
  end

  # Internal method.
  def _after_create
    disable if @disabled

    if [:text, :password, :number].include?(@options[:type])
      `#{@element}.addEventListener("keydown",function(e){self.$keydowned(e);})`
    end
  end

  # Callback for :text, :password, :number types.
  # Catches 'enter' key and calls `entered`.
  def keydowned(event)
    entered if Native(event).keyCode == 13
  end

  # Callback for :text, :password, :number types.
  # Override this method to catch the 'enter' key.
  def entered;end

  # Disable this input.
  def disable
    set_attribute(:disabled, :disabled)
  end

  # Enable this input.
  def enable
    remove_attribute(:disabled)
  end
end

# Creates a label element.
# In the DOM creates a: <label>.
# Specify option :for with the id of the input as value
# to set couple the label to an input.
class FerroFormLabel < FerroElement

  # Internal method.
  def _before_create
    @domtype = :label
  end
end

# Creates a fieldset element.
# In the DOM creates a: <fieldset>.
# Specify option :legend to set a title.
class FerroFormFieldset < FerroElement

  # Internal method.
  def _before_create
    @domtype = :fieldset
    @legend  = @options[:legend]
  end
end

# Creates a textarea input element.
# In the DOM creates a: <textarea>.
# Specify option :size to set its size.
# Default size is: { rows: 40, cols: 5 }.
class FerroFormTextarea < FerroElement

  # Internal method.
  def _before_create
    @domtype = :textarea
    @size    = { rows: 40, cols: 5 }
  end
end

# Creates a form output element.
# In the DOM creates a: <output>.
class FerroFormOutput < FerroElement

  # Internal method.
  def _before_create
    @domtype = :output
  end
end

# Container class for all clickable elements.
class FerroFormClickable < FerroFormInput

  # Internal method.
  def _after_create
    `#{@element}.addEventListener("click",function(e){#{clicked};document.activeElement.blur()})`
    super
  end

  # Override this method to define what happens after
  # element has been clicked.
  def clicked;end
end

# Creates a form button.
# In the DOM creates a: <input type='button'>.
class FerroFormButton < FerroFormClickable

  # Internal method.
  def _before_create
    @options[:type] = :button
    super
  end
end

# Creates a form submit button.
# In the DOM creates a: <input type='submit'>.
class FerroFormSubmit < FerroFormClickable

  # Internal method.
  def _before_create
    @options[:type] = :submit
    super
  end
end

# Creates a clickable block element.
# In the DOM creates a: <div>.
class FerroFormBlock < FerroFormClickable

  # Internal method.
  def _before_create
    super
    @domtype = :div
  end
end

# Creates a clickable checkbox.
# In the DOM creates a: <input type='checkbox'>.
class FerroFormCheckBox < FerroFormClickable

  # Internal method.
  def _before_create
    @options[:type] = :checkbox
    super
  end

  # Test if checkbox is checked.
  #
  # @return [Boolean] True if checkbox is checked
  def checked?
    `#{@element}.checked`
  end
end

# Creates a select list with options.
# In the DOM creates a: <select> and <option>.
# Specify option :list = Hash to set selectable options.
class FerroFormSelect < FerroElement

  # Internal method.
  def _before_create
    @domtype = :select
    @list = option_replace :list, {}
    super
  end

  # Internal method.
  # TODO Use _after_create
  def after_create
    @list.each do |value, content|
      add_option(value, content)
    end

    `#{@element}.addEventListener("change",function(e){#{changed};document.activeElement.blur()})`
    super
  end

  # Override this method to specify what happens after the
  # select elements value is changed.
  def changed;end

  # Manually add an option to the select element
  #
  # @param [String, Symbol] value Key of the option
  # @param [String] content Content to be displayed in the select list
  # @return [FerroElementVar] Returns the newly created element
  def add_option(value, content)
    add_child(
      "opt_#{value}",
      FerroElementVar,
      domtype: :option,
      value: value,
      content: content
    )
  end

  # Returns the currently selected option.
  #
  # @return [Hash] Returns a hash with keys: :option and :text
  def selection
    option = `#{element}.options[#{element}.selectedIndex].value`
    text   = `#{element}.options[#{element}.selectedIndex].text`
    { option: option, text: text }
  end

  # Set the selected option.
  #
  # @param [String, Symbol] option Key of the option
  def select(option)
    `for(var i=0; i < #{element}.options.length; i++) {
      if (#{element}.options[i].value === #{option}) {
        #{element}.selectedIndex = i;
        break;
      }
    }`
  end
end