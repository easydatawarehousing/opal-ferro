# @title Getting started with Opal-Ferro

# Getting started with Opal-Ferro

Ferro is a small Ruby library on top of [Opal](http://opalrb.com/)
that enables an object-oriented programming style for creating code
that runs in the webbrowser.
No more distractions like HTML and searching for DOM elements,
just beautiful and simple Ruby code. Front-End-Ruby-ROcks!


* [How does Ferro work](#ferro)
* [Creating the Master Object Model](#mom)
* [Adding elements](#demo)
* [Creation lifecycle](#lifecycle)
* [Navigating the Master Object Model](#navigating)
* [Styling Ferro elements](#styling)
* [Using a compositor to style elements](#compositor)
* [More information](#more)

<a name="ferro"></a>

## How does Ferro work?
Ferro uses an object oriented programming style. You instantiate an object, that object
in turn instantiates more child objects and add these as instance variables to itself.
And so on, producing a hierarchy of object instances.
This is called the Master Object Model (MOM).

When an object is instanciated in the MOM, Ferro will add an element to the webbrowsers
Document Object Model (DOM). The MOM keeps a reference to every DOM element.
This erradicates the need for element lookups (jquery $ searches).
If you need an element you know where to find it in the MOM.
Getter methods are automatically added by Ferro for easy access to instance variables.

Each object in the MOM inherits from a Ferro class.
Which Ferro class you use determines what type of DOM element will be created.
All Ferro classes inherit from one base class: Ferro::BaseElement.
For most DOM elements in the html specs there is a corresponding Ferro class.
For instance if you need a html5 `<header>` element you would create a class that inherits
from Ferro::Component::Header.  
Other html elements have a more abstract counterpart:
all text elements (`<p>`, `<h1>` .. `<h6>`) have one Ferro class `Ferro::Element::Text`.
The size of the text element is an option when you instantiate the object.

<a name="mom"></a>

## Creating the Master Object Model

First we need a class that inherits from FerroDocument.
This is the staring point for any Ferro application.
The Document instance will attach itself in the DOM to
`document.body`.

In the example below, the Document instance will create one child element.

    class Document < Ferro::Document

      # The cascade method is called after the Document
      # has been created and is ready to create child
      # objects.
      def cascade
        add_child :demo, Demo
      end
    end

To start the application one instance of the Document must be created.
In the `application.js` file (if you are using Rails for instance)
`Document.new` is called when the browser has loaded the necessary
files.

    `document.addEventListener("DOMContentLoaded", function() {#{Document.new};})`

The backticks are Opal's way of entering _raw_ Javascript. Using
familiar Ruby string interpolation `#{}` a reference to `Document.new` can
be inserted.
This is the first and last line of Javascript that is needed.
Everyting else is Ruby code.

<a name="demo"></a>

## Adding elements

Let's look at a very simple example. We will define a small component
with a title and a button. The button should change the title text when clicked.

    class Demo < Ferro::Component::Base
      def cascade
        # Add a title
        add_child :title, Ferro::Element::Text, size: 4, content: 'Title'

        # Add a button
        add_child :btn, DemoButton, content: 'Click me'
      end

      def rotate_title
        # We have access to the 'title' instance variable
        txt = title.get_text
        title.set_text (txt[1..-1] + txt[0]).capitalize
      end
    end

    class DemoButton < Ferro::Form::Button
      def clicked
        # Every element knows its parent
        parent.rotate_title
      end
    end

The code in Demo _cascade_ method is equivalent to something like this,
which should look more familiar to a Ruby programmer:

    class Demo
      def initialize
        @title = Ferro::Element::Text.new(size: 4, content: 'Title')
        @btn   = DemoButton.new(content: 'Click me')
      end
    end

Just like above, the `add_child` method will create instance variables
`@title` and `@btn`. In Ferro we don't need to use the @.

<a name="lifecycle"></a>

## Creation lifecycle

Every Ferro class has 3 hooks into the object creation lifecycle:

- before_create
- after_create
- cascade

The first two are called just before and after the object itself
is created. The cascade hook is called when the object is ready
to create child objects.  
In this example most of the action happens in the _cascade_ method.

By inheriting from _Ferro::Form::Button_, _DemoButton_ has access
to the click event handler. After a click occurred, it signals
its parent (_Demo_) to rotate the title text.

<a name="navigating"></a>

## Navigating the Master Object Model

There are two ways to navigate around the MOM: upward and downward.
Every object in the MOM knows its parent. If an event is received by an
object like a button, the parent of that object usually can handle the
event. The parent element can be accessed using the `parent` method.

Searching upward further than one parent quickly becomes difficult to
follow. So you can always search downward starting from the top.
Every object in the MOM can access the root object using the `root`
method. From the root you can access all MOM objects.

There is a shortcut to find an object starting from the nearest element
in the hierarchy that is a component. All semantical elements
(like header and section) are components. All objects that are children
of a component have immediate access to that component using the
`component` method.

<a name="styling"></a>

## Styling Ferro elements

The created elements still need some styling. Ferro uses a handy
naming convention: CSS classnames match Ruby classnames.
For example:

    class DemoButton < Ferro::Form::Button
    end

When we create this button in the MOM, its DOM counterpart receives
two classnames. One matching the Ruby classname `DemoButton` and
one for its Ruby superclass `FerroFormButton`.
These classnames are _dasherized_. In CSS you can reference these
classnames as `demo-button` and `ferro-form-button`.

<a name="compositor"></a>

## Using a compositor to style elements

There is alternative way to add styling to generated DOM objects.
In your `Document` you can set a `Compositor` object.
A compositor maps Ruby class names to a list of CSS class names.
When a Ferro object is created its class name is looked up in the
compositor mapping. If found the list of CSS classes will be added
to the corresponding DOM element.  
The mapping is simply a Ruby Hash. The keys are Ruby class names,
the values are CSS class names.  
Optionally you can use the theme parameter to create different
mappings per theme. Use the `Document.switch_compositor_theme`
method to switch themes at run time.  
Add the compositor like this:

    class Document < Ferro::Document
      def before_create
        @compositor = MyCompositor.new :dark
      end
    end

The theme parameter is optional. A simple mapping might look like this:

    class MyCompositor < Ferro::Compositor

      def map(theme)
        m = {
          'Document' => %w{black bg-white sans-serif},
          'Banner'   => %w{w-100},
        }
        
        if theme == :dark
          m['Document'] = %w{white bg-black sans-serif}
        end

        m
      end
    end


<a name="more"></a>

## More information

Please see the [Ferro website](https://easydatawarehousing.github.io/ferro/)
for more information and examples.
The [source code](https://github.com/easydatawarehousing/ferro)
for that webapp is a good Ferro example in itself.

For some simple boilerplate code to get started with Ferro you can use
[this Rails example](https://github.com/easydatawarehousing/ferro-example-todolist).
