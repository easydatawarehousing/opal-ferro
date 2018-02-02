class FerroForm < FerroElement
  def _before_create
    # Dont use a real <form> so we don't have to prevent default actions
    @domtype  = :div
  end
end

# :text, :password, :reset, :radio, :checkbox, :color,
# :date, :datetime-local, :email, :month, :number,
# :range, :search, :tel, :time, :url, :week
class FerroFormInput < FerroElement
  def _before_create
    @domtype = :input
    @options[:type] ||= :text
    @options[:value] = option_replace :content
    @disabled = option_replace :disabled, false
  end

  def value
    `#{@element}.value`
  end

  def value=(value)
    `#{@element}.value = #{value}`
  end

  def set_focus
    # Doesn't work ?!
    `#{element}.focus()`
  end

  def _after_create
    disable if @disabled

    if [:text, :password, :number].include?(@options[:type])
      `#{@element}.addEventListener("keydown",function(e){self.$keydowned(e);})`
    end
  end

  def keydowned(event)
    entered if Native(event).keyCode == 13
  end

  def entered;end

  def disable
    set_attribute(:disabled, :disabled)
  end

  def enable
    remove_attribute(:disabled)
  end
end

class FerroFormLabel < FerroElement
  def _before_create
    @domtype = :label
  end
end

class FerroFormFieldset < FerroElement
  def _before_create
    @domtype = :fieldset
    @legend  = @options[:legend]
  end
end

class FerroFormTextarea < FerroElement
  def _before_create
    @domtype = :textarea
    @size    = { rows: 40, cols: 5 }
  end
end

class FerroFormOutput < FerroElement
  def _before_create
    @domtype = :output
  end
end

class FerroFormClickable < FerroFormInput
  def _after_create
    `#{@element}.addEventListener("click",function(e){#{clicked};document.activeElement.blur()})`
    super
  end

  def clicked;end
end

class FerroFormButton < FerroFormClickable
  def _before_create
    @options[:type] = :button
    super
  end
end

class FerroFormSubmit < FerroFormClickable
  def _before_create
    @options[:type] = :submit
    super
  end
end

class FerroFormBlock < FerroFormClickable
  def _before_create
    super
    @domtype = :div
  end
end

# CheckBox with click callback
class FerroFormCheckBox < FerroFormClickable
  def _before_create
    @options[:type] = :checkbox
    super
  end

  def checked?
    `#{@element}.checked`
  end
end

# Select input
class FerroFormSelect < FerroElement
  def _before_create
    @domtype = :select
    @list = option_replace :list, {}
    super
  end

  def after_create
    @list.each do |value, content|
      add_option(value, content)
    end

    `#{@element}.addEventListener("change",function(e){#{changed};document.activeElement.blur()})`
    super
  end

  def changed;end

  def add_option(value, content)
    add_child "opt_#{value}", FerroElementVar, domtype: :option, value: value, content: content
  end

  def selection
    option = `#{element}.options[#{element}.selectedIndex].value`
    text   = `#{element}.options[#{element}.selectedIndex].text`
    { option: option, text: text }
  end

  def select(option)
    `for(var i=0; i < #{element}.options.length; i++) {
      if (#{element}.options[i].value === #{option}) {
        #{element}.selectedIndex = i;
        break;
      }
    }`
  end
end