require "test_helper"
require "eturem/ja/main"

class EturemJaTest < Minitest::Test
  def load_and_full_message(filename)
    exception = Eturem.load(filename)
    return nil unless exception.is_a?(Exception)
    Eturem.extend_exception(exception)
    exception.eturem_full_message(highlight: false).strip + "\n"
  end

  def setup
    Eturem::Base.output_backtrace = false
    Eturem::Base.output_original  = false
    Eturem::Base.output_script    = true
    Eturem::Base.use_coderay      = false
    Eturem::Base.before_line_num  = 2
    Eturem::Base.after_line_num   = 2
  end
  
  def test_that_it_has_a_version_number
    refute_nil ::Eturem::VERSION
  end
  
  def test_valid_script_return_nil
    assert_nil load_and_full_message("test/example0.rb")
  end
  
  def test_syntax_error
    assert_equal load_and_full_message("test/example1.rb"), <<-'EOS'
【エラー】ファイル"test/example1.rb" 6行目：(SyntaxError)
（ただし、実際のエラーの原因はおそらく6行目より前にあります。）
構文エラーです。 end が足りない可能性があります。「if」に対応する「end」があるか確認してください。
    4:     puts "なんたらかんたら"
    5:   # 内側の if に対応する end を忘れてしまった！
 => 6: end
EOS
  end
  
  def test_name_error
    assert_equal load_and_full_message("test/example2.rb"), <<-'EOS'
【エラー】ファイル"test/example2.rb" 6行目：(NameError)
変数/メソッド「player_life」は存在しません。「prayer_life」の入力ミスではありませんか？
    2: prayer_life = 100
       :
    4: # 中略
    5: # ↓このスペルは正しいが、上でミスしたことでエラー発生。
 => 6: puts "dead!" if player_life <= 0
    7: # 後略
EOS
  end
  
  def test_argument_error
    assert_equal load_and_full_message("test/example3.rb"), <<-'EOS'
【エラー】ファイル"test/example3.rb" 5行目：(ArgumentError)
引数の数が正しくありません。「foo」は本来 2 個の引数を取りますが、1 個の引数が渡されています。
    3: end
    4: # 中略
 => 5: foo(1)
EOS
  end

  def test_unexpected_nil
    assert_equal load_and_full_message("test/example4.rb"), <<-'EOS'
【エラー】ファイル"test/example4.rb" 3行目：(NoMethodError)
nil に対して succ というメソッドを呼び出そうとしています。
変数の値/メソッドの返値が予期せず nil になっている可能性があります。
    1: # Unexpected nil
    2: a = [1,2,3]
 => 3: b = a[3].succ
EOS
  end
  
  def test_multibyte_space
    assert_equal load_and_full_message("test/example5.rb"), <<-'EOS'
【エラー】ファイル"test/example5.rb" 2行目：(NameError)
スクリプト中に全角空白が混じっています。
    1: # Multibyte space
 => 2: a =　1
EOS
  end
end
