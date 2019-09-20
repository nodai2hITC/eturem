# Eturem

Ruby のエラーメッセージを、初心者にわかりやすく表示するための gem です。

Easy To Understand Ruby Error Message の略。

## インストールと使用方法

    $ gem install eturem

でインストールし、

    $ ruby -returem/ja <your_script.rb>

と使用すればよいのですが、最初に書いたとおり初心者が使用することを想定した gem ですので、そんなことを初心者に強いるのは酷というもの。だれか詳しい人が、事前に ```gem install eturem``` した上で、環境変数 RUBYOPT に ```-returem/ja``` を追加しておいてあげましょう。

## 使用するとどうなるか

* エラーメッセージが日本語で表示される。
* エラー箇所周辺が表示される。
* エラーの種類によっては、原因を特定するためのさらなる情報が表示される。

### 例１：SyntaxError

```ruby
if gets.to_i == 1
  if gets.to_i == 2
    puts "なんたらかんたら"
  # 内側の if に対応する end を忘れてしまった！
end
```

通常の環境で実行すると、次のようなエラーが表示されます。

```
example1.rb:5: syntax error, unexpected end-of-input, expecting keyword_end
```

英語の苦手な人ではこの時点で拒否反応が出るでしょうし、そうでなくとも「end-of-input」や「keyword_end」が何を意味しているのか、初心者には掴みにくいのではないでしょうか。

Eturem を使用すると、次のようなエラー表示になります。

```
【エラー】ファイル"example1.rb" 5行目：
（ただし、実際のエラーの原因はおそらくもっと前にあります。）
構文エラーです。endが足りません。「if」に対応する「end」があるか確認してください。
    3:     puts "なんたらかんたら"
    4:   # 内側の if に対応する end を忘れてしまった！
 => 5: end
```

このように、日本語でわかりやすくエラーを表示してくれます。

### 例２：NameError

```ruby
prayer_life = 100
# ↑スペルミス！
# 中略
# ↓このスペルは正しいが、上でミスしたことでエラー発生。
if player_life > 0
# 後略
```

通常の環境で実行すると、次のようなエラーが表示されます。

```
example2.rb:5:in `<main>': undefined local variable or method `player_life' for main:Object (NameError)
Did you mean?  prayer_life
```

did_you_mean のおかげで昔より格段にわかりやすくなったとはいえ、それでも英語に壁を感じる人はいますし、またこの例の場合実際にミスをしたのは1行目にもかかわらず「5行目でエラー」と表示されてしまうため、「え？5行目を何度見てもミスなんて無いよ？」と困ってしまう人もいるでしょう。

Eturem を使用すると、次のようなエラー表示になります。（実際には色付き）

```
【エラー】ファイル"example2.rb" 5行目：
変数/メソッド「player_life」は存在しません。「prayer_life」の入力ミスではありませんか？
    1: prayer_life = 100
       :
    3: # 中略
    4: # ↓このスペルは正しいが、上でミスしたことでエラー発生。
 => 5: if player_life > 0
    6: # 後略
```

このように、エラー発生箇所周辺だけではなく、did_you_mean がサジェストしてくれた変数の使用行も同時に表示してくれるので、ミスをしたのが実は1行目であることに気付きやすくなるのではないでしょうか。

### 例３：ArgumentError

```ruby
def foo(a, b)
end
# 中略
foo(1)
```

通常の環境で実行すると、次のようなエラーが表示されます。

```
Traceback (most recent call last):
        1: from example3.rb:4:in `<main>'
example3.rb:1:in `foo': wrong number of arguments (given 1, expected 2) (ArgumentError)
```

このように、ArgumentError のエラー発生行は、メソッド定義行（この場合1行目）になってしまいます。しかし実際に ArgumentError が発生するときの原因は、メソッド定義部分ではなく、呼び出し部分であることがほとんどではないでしょうか？

この例の場合 Traceback に「from example3.rb:4」と表示されてはいますが、初心者にはやはりわかりにくいのではないかと思われます。

Eturem を使用すると、次のようなエラー表示になります。

```
【エラー】ファイル"example3.rb" 4行目：
引数の数が正しくありません。「foo」は本来2個の引数を取りますが、1個の引数が渡されています。
    2: end
    3: # 中略
 => 4: foo(1)
```

このように、呼び出し行をエラー発生行として表示してくれます。

### 例４：warning

0.4.0 から、warning に対してもサポートができるようになりました。

```
【警告】ファイル"example4.rb" 2行目：
条件式部分で「 = 」が使われています。「 == 」の間違いではありませんか？
 => 2: puts "a" if a = 1
```

現状「条件式内での = 使用」のみにしか対応していませんが、上記のように日本語での警告に加えて該当行を表示することができます。

### 例５：エラー発生時に自動で binding.irb

変数の値が不適切だったためにエラーが起きた可能性がある場合、エラーが起きた瞬間の変数の値を調べる必要があります。そうした際には「エラー発生箇所の直前に binding.irb を入れて調べる」という手がありますが、そうするとたまにしか起きないエラーの場合何度も binding.irb が動いてしまって面倒です。

そこで、後述する設定ファイル .eturem で設定するか、あるいはプログラム中に `$eturem_repl = "irb"` と入れておくことで、エラー発生時に自動的に binding.irb することができます。

なお、この機能だけを切り出した gem「[autoirb](https://github.com/nodai2hITC/autoirb)」もあります。

## .eturem ファイルによる設定

HOME に「.eturem」というファイルを用意すると、詳細設定ができます。

```
enable: true
debug: false
lang: en
output_backtrace: true
output_original: true
output_script: true
use_coderay: false
before_line_num: 2
after_line_num: 2
repl: nil
```

- enable: eturem の使用/不使用を切り替えます。
- debug: eturem 自体をデバッグするための機能なので、使う必要はありません。
- lang: 表示言語を切り替えます。ただし、`-returem/ja` のように言語を指定して使用した場合、この設定よりもそちらが優先されます。
- output_backtrace: バックトレース表示の有無を切り替えます。
- output_original: Ruby 本来のエラーメッセージの表示の有無を切り替えます。
- output_script: エラーの起きた個所のスクリプト表示の有無を切り替えます。
- before_line_num / after_line_num: スクリプト表示の際、エラー行の前後何行を表示するかを設定します。
- repl: irb または pry と書いておくと、エラー発生時に binding.irb / binding.pry します。

## Contributing

「こう表示した方がよりわかりやすいのでは？」等のご意見ありましたら、よろしく御願いします。

Bug reports and pull requests are welcome on GitHub at https://github.com/nodai2hITC/eturem. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Eturem project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/nodai2hITC/eturem/blob/master/CODE_OF_CONDUCT.md).
