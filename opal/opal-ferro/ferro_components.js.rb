# A component with a text entry field and submit button
class FerroFormSearch < FerroForm
  
  def _before_create
    @button_text = option_replace :button_text, ' '
    @placeholder = option_replace :placeholder, ' Search...'
  end

  def cascade
    add_child :entry,  FerroFormSearchInput,  { placeholder: @placeholder }
    add_child :submit, FerroFormSearchSubmit, { content: @button_text }
  end

  def do_submit
    value = entry.value.strip
    submitted(value) if !value.empty?

    entry.toggle_state :search_input_open
    submit.toggle_state :search_submit_open

    entry.value = nil
    entry.set_focus if entry.state_active?(:search_input_open)
  end

  def submitted(value);end
end

class FerroFormSearchInput < FerroFormInput

  def _after_create
    add_state :search_input_open
    super
  end

  def entered
    parent.do_submit
  end
end

class FerroFormSearchSubmit < FerroFormButton

  def _after_create
    add_state :search_submit_open
    super
  end

  def clicked
    parent.do_submit
  end
end

# A simple pull-down menu
# @option[items]: a list of classes
class FerroPullDown < FerroElementBlock

  def _before_create
    @title_text = option_replace :title, '='
    @items      = option_replace :items, []
    super
  end

  def _after_create
    add_state :pull_down_open
    super
  end

  def cascade
    add_child :title, FerroPullDownTitle, { content: @title_text }
    add_child :items, FerroPullDownItems, { items:   @items }
  end
end

class FerroPullDownTitle < FerroFormBlock
  def clicked
    parent.toggle_state :pull_down_open
  end
end

class FerroPullDownItems < FerroElementBlock

  def _before_create
    @id       = FerroSequence.new 'pdi_'
    @itemlist = option_replace :items, []
    super
  end

  def cascade
    @items = @itemlist.map do |item|
      add_child @id.next, item
    end
  end
end