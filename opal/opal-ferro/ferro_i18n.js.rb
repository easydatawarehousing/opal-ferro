module Ferro

  # Adds support for localization.
  # Add `require 'opal-ferro/ferro_i18n'` to use this optional
  # module.
  #
  # Locales are stored in the DOM as template elements.
  # Like: <template class='i18n' data-lang='en'>.
  # Templates are never rendered by the browser.
  # This i18n implementation is basically a key-value store
  # located in the DOM.
  #
  # Either add a locale template when rendering the
  # html for the page or add it at run-time using
  # the 'add_locale' method.
  # Note that older browsers (IE) dont support templates.
  #
  # All strings in the template are 'trusted'. Ie they may
  # contain html markup like <b> and <i>.
  # Even <script> tags are possible but definitely not recommended.
  #
  # Note that there are no private methods in Opal. Methods that
  # should be private are marked in the docs with 'Internal method'
  # and start with an underscore.
  class I18n

    # Create the I18n provider.
    # The current locale will be set to the value provided or
    # if not specified or not found the first locale found.
    #
    # @param [String] locale, the preferred locale.
    def initialize(locale = nil)
      @template = nil
      _find_template locale
    end

    # Get localized string.
    # Strings can be referenced by an id.
    # Note that the common pattern of referencing nested
    # resource separated with a dot ('main.group.string')
    # is possible. Inside the html template string id's
    # should be separated with a dash ('main-group-string').
    #
    # @param [String] id of the string.
    # @param [String] options to substitute placeholders with.
    #   Some characters (<, >) within an option will be escaped.
    # @return [String] Localized string.
    def t(id, options)
      _replace_options _find_string(id), options
    end

    # Add a locale to the dom body element as a <template> element.
    #
    # @param [String] locale, locale id of strings.
    # @param [Hash] strings, a hash holding localized strings.
    # @return [Boolean] returns true if template added succesfully
    def add_locale(locale, strings)
      if locale.to_s != '' && strings.is_a?(Hash) && strings.length > 0
        _add_locale(locale, strings)
        true
      else
        false
      end
    end

    # Set current locale.
    # If locale is not found the current locale is kept.
    #
    # @param [String] locale, locale id of strings.
    def set_locale(locale)
      _find_template locale
    end

    # Is I18n supported by the webbrowser.
    #
    # @return [Boolean] returns true if template elements are
    #   supported by the webbrowser.
    def i18n_supported?
      `('content' in document.createElement('template'))`
    end

    private

    # Internal method to locate the requested template.
    def _find_template(locale)
      q = "document.querySelector(\"template.i18n[data-lang='#{locale}']\")"
      template = `eval(#{q})`

      @template = if `template && template !== 'null'`
        `template.content`
      elsif @template
        @template
      else 
        template = `document.querySelector('template.i18n')`
        if `template && template !== 'null'`
          `template.content`
        else
          nil
        end
      end
    end

    # Internal method to find a string in the current locale
    # and unescape < and >.
    def _find_string(id)
      if @template
        q = "##{id.gsub('.', '-')}"
        e = `#{@template}.querySelector(#{q})`
        return `#{e}.textContent` if `#{e} && #{e} !== 'null'`
      end

      nil
    end

    # Internal method to substitute placeholders with a value.
    def _replace_options(string, options)
      # Unescape the string so we can use the returned string
      # to set an elements inner html.
      s = string.gsub('&lt;', '<').gsub('&gt;', '>')

      if options
        # But escape option values to prevent code injection
        s.gsub(/%\{(\w+)\}/) do |m|
          key = ($1 || m.tr("%{}", ""))

          if options.key?(key)
            options[key].to_s.gsub('<', '&lt;').gsub('>', '&gt;')
          else
            key
          end
        end
      else
        s
      end
    end

    # Internal method to add a template to DOM body element.
    def _add_locale(locale, strings)
      `t = document.createElement('template');
      document.body.appendChild(t);
      t.classList.add('i18n');
      t.setAttribute('data-lang', #{locale})`

      strings.each do |k, v|
        `e=document.createElement('p');
        t.content.appendChild(e);
        e.id=#{k.gsub('.', '-')};
        e.textContent=#{v}`
      end
    end
  end
end