require "test_helper"

class EturemJaTest < Minitest::Test
  module StringExt
    refine String do
      def format
        self.gsub(/\e\[[0-9;]+m/, "").gsub(/\R/, "\n").strip + "\n"
      end
    end
  end
  
  using StringExt
  
  def setup
    Eturem.set_config(
      output_backtrace: false,
      output_original: false,
      output_script: true,
      use_coderay: false,
      before_line_num: 2,
      after_line_num: 2
    )
  end
  
  def test_that_it_has_a_version_number
    refute_nil ::Eturem::VERSION
  end
  
  def test_valid_script_return_nil
    assert_nil Eturem.load("test/example0.rb")
  end
  
  def test_syntax_error
    assert_equal Eturem.load("test/example1.rb").inspect.format, <<'EOS'
【エラー】ファイル"test/example1.rb" 6行目：
（ただし、実際のエラーの原因はおそらくもっと前にあります。）
構文エラーです。endが足りません。「if」に対応する「end」があるか確認してください。
    4:     puts "なんたらかんたら"
    5:   # 内側の if に対応する end を忘れてしまった！
 => 6: end
EOS
  end
  
  def test_name_error
    assert_equal Eturem.load("test/example2.rb").inspect.format, <<'EOS'
【エラー】ファイル"test/example2.rb" 6行目：
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
    assert_equal Eturem.load("test/example3.rb").inspect.format, <<'EOS'
【エラー】ファイル"test/example3.rb" 5行目：
引数の数が正しくありません。「foo」は本来2個の引数を取りますが、1個の引数が渡されています。
    3: end
    4: # 中略
 => 5: foo(1)
EOS
  end

  def test_unexpected_nil
    assert_equal Eturem.load("test/example4.rb").inspect.format, <<'EOS'
【エラー】ファイル"test/example4.rb" 3行目：
nil に対して succ というメソッドを呼び出そうとしています。
変数の値/メソッドの返値が予期せず nil になっている可能性があります。
    1: # Unexpected nil
    2: a = [1,2,3]
 => 3: b = a[3].succ
EOS
  end
  
  def test_multibyte_space
    assert_equal Eturem.load("test/example5.rb").inspect.format, <<'EOS'
【エラー】ファイル"test/example5.rb" 2行目：
スクリプト中に全角空白が混じっています。
    1: # Multibyte space
 => 2: a =　1
EOS
  end
end
