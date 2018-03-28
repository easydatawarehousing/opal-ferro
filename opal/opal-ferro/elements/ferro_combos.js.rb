module Ferro

  # This module contains some combined elements.
  module Combo
    # Creates a form with a text input and a submit button.
    # Specify option :button_text to set the submit button text.
    # Specify option :placeholder to set a placeholder text for the input.
    # Two states are defined: search-input-open, search-submit-open
    # to define CSS rules.
    class Search < Form::Base
      
      # Internal method.
      def _before_create
        @button_text = option_replace :button_text, ' '
        @placeholder = option_replace :placeholder, ' Search...'
      end

      # Internal method.
      def cascade
        add_child :entry,  SearchInput,  { placeholder: @placeholder }
        add_child :submit, SearchSubmit, { content: @button_text }
      end

      # Internal method.
      def do_submit
        value = entry.value.strip
        submitted(value) if !value.empty?

        entry.toggle_state :search_input_open
        submit.toggle_state :search_submit_open

        entry.value = nil
        entry.set_focus if entry.state_active?(:search_input_open)
      end

      # Override this method to specify what happens when
      # submit button is clicked or enter key is pressed.
      #
      # @param [String] value The value of the text input.
      def submitted(value);end
    end

    # Internal class for use with {Search}.
    class SearchInput < Form::Input

      # Internal method.
      def _after_create
        add_state :search_input_open
        super
      end

      # Internal method.
      def entered
        parent.do_submit
      end
    end

    # Internal class for use with {Search}.
    class SearchSubmit < Form::Button

      # Internal method.
      def _after_create
        add_state :search_submit_open
        super
      end

      # Internal method.
      def clicked
        parent.do_submit
      end
    end

    # Creates a simple pull-down menu.
    # Specify option :title to set the menu title text.
    # Specify option :items as an Array of Ferro classes.
    # Each class should be something clickable, for instance a
    # FormBlock. These classes will be instanciated by
    # this element.
    class PullDown < BaseElement

      # Internal method.
      def _before_create
        @title_text = option_replace :title, '='
        @items      = option_replace :items, []
        super
      end

      # Internal method.
      def _after_create
        add_state :pull_down_open
        super
      end

      # Internal method.
      def cascade
        add_child :title, PullDownTitle, { content: @title_text }
        add_child :items, PullDownItems, { items:   @items }
      end
    end

    # Internal class for use with {PullDown}.
    # This element has a state: pull-down-open
    # to define CSS rules.
    class PullDownTitle < Form::Block

      # Internal method.
      def clicked
        parent.toggle_state :pull_down_open
      end
    end

    # Internal class for use with {PullDown}.
    class PullDownItems < BaseElement

      # Internal method.
      def _before_create
        @id       = Sequence.new 'pdi_'
        @itemlist = option_replace :items, []
        super
      end

      # Internal method.
      def cascade
        @items = @itemlist.map do |item|
          add_child @id.next, item
        end
      end
    end
  end
end