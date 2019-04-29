module Ferro

  # This module contains all semantic elements.
  module Component
    # A generic component element.
    # In the DOM creates a: <div>.
    # All semantical elements inherit from this class.
    class Base < BaseElement

      # Return self when called by children / descendants.
      def component
        self
      end
    end

    # Creates a semantical element.
    # This is a component.
    # In the DOM creates a: <header>.
    class Header < Base

      # Internal method.
      def _before_create
        @domtype = :header
      end
    end

    # Creates a semantical element.
    # This is a component.
    # In the DOM creates a: <nav>.
    class Navigation < Base

      # Internal method.
      def _before_create
        @domtype = :nav
      end
    end

    # Creates a semantical element.
    # This is a component.
    # In the DOM creates a: <main>.
    class Main < Base

      # Internal method.
      def _before_create
        @domtype = :main
      end
    end

    # Creates a semantical element.
    # This is a component.
    # In the DOM creates a: <section>.
    class Section < Base

      # Internal method.
      def _before_create
        @domtype = :section
      end
    end

    # Creates a semantical element.
    # This is a component.
    # In the DOM creates a: <article>.
    class Article < Base

      # Internal method.
      def _before_create
        @domtype = :article
      end
    end

    # Creates a semantical element.
    # This is a component.
    # In the DOM creates a: <aside>.
    class Aside < Base

      # Internal method.
      def _before_create
        @domtype = :aside
      end
    end

    # Creates a semantical element.
    # This is a component.
    # In the DOM creates a: <footer>.
    class Footer < Base

      # Internal method.
      def _before_create
        @domtype = :footer
      end
    end
  end
end