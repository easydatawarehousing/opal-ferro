# 0.11.0 - April 10, 2019

[0.11.0]: https://github.com/easydatawarehousing/opal-ferro/compare/v0.10.2...v0.11.0

- Dont add ruby classnames to DOM elements when using the style compositor
- Add underscore prefix to dom id's to ensure id's are strings
- Added dom_id and value= methods
- Added button and video elements
- Updated opal version to 0.11+

# 0.10.2 - June 1, 2018

[0.10.2]: https://github.com/easydatawarehousing/opal-ferro/compare/v0.10.1...v0.10.2

- Added the style compositor to map Ruby classnames to CSS classnames
- Fixed: don't add clicks on an anchor to the browser history when the href is empty

# 0.10.1 - March 31, 2018

- Added documentation (using Yard)
- Modularized Ferro (breaking change), see below
- AJAX can now handle any type of request (not just get)

To upgrade from 0.10.0 to 0.10.1:

- replace FerroDocument with Ferro::Document
- replace FerroXhr with Ferro::Xhr
- replace FerroSequence with Ferro::Sequence
- replace FerroElementForm with Ferro::Form::Base
- replace FerroElementForm... with Ferro::Form::...
- replace FerroElementComponent with Ferro::Component::Base
- replace FerroElementComponent... with Ferro::Component::...
- replace FerroSearch with Ferro::Combo::Search
- replace FerroPullDown with Ferro::Combo::PullDown
- replace FerroElement... with Ferro::Element::...


# 0.10.0 - February 2, 2018

Initial version
