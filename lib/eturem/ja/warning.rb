# coding: utf-8

module Eturem
  module Base
    def self.warning_message(path, lineno, warning)
      str = "\e[1;33m【警告】\e[0m" +
        (path == "(eval)" ? "eval 中の" : %<ファイル"#{path}" #{lineno}行目：>) +
        (@@eturem_output_original ? "#{warning}\n" : "\n")
      script_lines = Eturem::Base.read_script(path)
      linenos = [lineno]
      case warning
      when "found `= literal' in conditional, should be =="
        Eturem::Base.highlight(script_lines[lineno], "=", "\e[4;33m")
        str += "条件式部分で「 = 」が使われています。「 == 」の間違いではありませんか？"
      when /^assigned but unused variable - (\S+)/
        var_name = $1
        Eturem::Base.highlight(script_lines[lineno], var_name, "\e[4;33m")
        str += "変数「#{var_name}」が割り当てられていますが、その後一度も使用されていません。"
      when /mismatched indentations at '([^']+)' with '([^']+)' at (\d+)/
        keyword1, keyword2, lineno2 = $1, $2, $3.to_i
        linenos.push(lineno2)
        Eturem::Base.highlight(script_lines[lineno ], keyword1, "\e[4;33m")
        Eturem::Base.highlight(script_lines[lineno2], keyword2, "\e[4;33m")
        str += "この行の「#{keyword1}」と、それに対応した #{lineno2}行目の「#{keyword2}」のインデントが揃っていません。"
      when /already initialized constant (\S+)/
        const = $1
        Eturem::Base.highlight(script_lines[lineno], const, "\e[4;33m")
        str += "定数「#{const}」は既に定義されています。"
      when /previous definition of (\S+) was here/
        const = $1
        Eturem::Base.highlight(script_lines[lineno], const, "\e[4;33m")
        str = (path == "(eval)" ? "eval 中の" : %<ファイル"#{path}" #{lineno}行目：>)
        str += (@@eturem_output_original ? "#{warning}\n" : "\n")
        str += "（ここで「#{const}」の定義がされています。）"
      else
        return nil
      end
      script = @@eturem_output_script ? Eturem::Base.script(script_lines, linenos, lineno) : ""
      "#{str}\n#{script}\n"
    end
  end
end
