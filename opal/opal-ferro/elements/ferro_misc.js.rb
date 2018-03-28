module Ferro
  module Element
    # Creates a miscellaneous element.
    # In the DOM creates a: <img>.
    # Will be changed to use <figure> and <figcaption>
    # Specify option :src to set the source url.
    class Image < BaseElement

      # Internal method.
      def _before_create
        @domtype = :img
        @options[:alt] ||= @options[:src]
      end
    end

    # Creates a miscellaneous element.
    # In the DOM creates a: <canvas>.
    class Canvas < BaseElement

      # Internal method.
      def _before_create
        @domtype = :canvas
      end
    end

    # Creates a miscellaneous element.
    # In the DOM creates a: <script>.
    # Specify option :invoke = false to prevent the script
    # from being executed.
    class Script < BaseElement

      # Internal method.
      def _before_create
        @domtype = :script
        @run     = option_replace :invoke, true
      end

      # Internal method.
      def _after_create
        load
        invoke if @run
      end

      # Override method to specify the content of the Javascript.
      def load;end

      # Override method to specify the execution of the script.
      def invoke;end
    end

    # Creates any kind of element depending on option :domtype.
    class Var < BaseElement

      # Internal method.
      def _before_create
        @domtype = option_replace :domtype, :div
      end
    end
  end
end