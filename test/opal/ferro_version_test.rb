require 'test_helper'

class Opal::FerroTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Opal::Ferro::VERSION
  end
end
