require "test_helper"

class EturemTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Eturem::VERSION
  end

  def test_eval
    normal_script = <<EOS
puts "Hello, World!"
EOS
    assert Eturem.eval(normal_script) == nil

    syntax_error_script = <<EOS
if 1==1
  puts "1 equal 1"
# no end!
EOS
    assert Eturem.eval(syntax_error_script).exception.is_a? SyntaxError
  end
end
