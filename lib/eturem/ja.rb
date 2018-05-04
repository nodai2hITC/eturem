# coding: utf-8

require "eturem/base"

module Eturem
  class Ja < Base
    def prepare
      super
      case @exception.class.to_s
      when "DXRuby::DXRubyError"
        @exception_s.force_encoding("sjis") if @exception_s.encoding == Encoding::ASCII_8BIT
        @exception_s.encode!("UTF-8")
      end
    end
    
    def traceback_most_recent_call_last
      "エラー発生までの流れ:"
    end
    
    def location_inspect(location, label)
      "\"#{location.path}\" #{location.lineno}行目: '#{label}'"
    end
    
    def output_exception
      puts exception_inspect
    end

    def exception_inspect
      ret = original_exception_inspect.chomp + "\n" + "ファイル\"#{@path}\" #{@lineno}行目でエラーが発生しました。\n"
      case @exception
      when LoadError
        return ret +
          "ファイル/ライブラリ '#{@exception.path}' が見つかりません。" +
          "ファイル/ライブラリ名を確認してください。"
      when SyntaxError
        return syntax_error_inspect(ret)
      when Interrupt
        return ret + "プログラムが途中で強制終了されました。"
      when ArgumentError
        if @given
          return ret +
            "引数の数が正しくありません。" +
            "「#{@method}」は本来" +
            (@expected =~ /^0$/ ? "引数が不要ですが、" : "#{@expected}個の引数を取りますが、") +
            "#{@given}個の引数が渡されています。"
        else
          return ret + "「#{@method}」への引数の数が正しくありません。"
        end
      when NameError, NoMethodError
        return name_error_inspect(ret)
      when TypeError
        return ret + "「#{@method}」への引数のタイプが正しくありません。"
      when ZeroDivisionError
        return ret + "割る数が 0 での割り算はできません。"
      else
        return ret
      end
    end
    
    def syntax_error_inspect(ret)
      unexpected = transform_syntax_error_keyword(@unexpected)
      expected   = transform_syntax_error_keyword(@expected)
      unexpected.each do |keyword|
        next unless keyword.match(/^「\s*(\S+)\s*」$/)
        highlight!(@script_lines[@lineno], Regexp.last_match(1), "\e[31m\e[4m")
      end
      keywords = get_keywords_from_script(%w[if unless case while until for begin def class module do])
      
      if @expected == "end-of-input" || @expected == "$end"
        ret += "構文エラーです。余分な#{unexpected.join('または')}があります。"
        ret += "「#{keywords.join(' / ')}」と「end」の対応関係を確認してください。" if @unexpected == "keyword_end"
        return ret
      elsif @unexpected == "end-of-input" || @unexpected == "$end"
        ret = ret.chomp + "（ただし、エラーの原因はおそらくもっと前にあります。）\n" +
              "構文エラーです。#{expected.join('または')}が足りません。"
        ret += "「#{keywords.join(' / ')}」に対応する「end」があるか確認してください。" if @expected == "keyword_end"
        return ret
      end
      return ret + "構文エラーです。" +
        "#{unexpected.join('または')}より前のどこかに、" +
        "#{expected.join('または')}を入れる必要があります。"
    end
    
    def transform_syntax_error_keyword(keyword)
      keyword.split(/\s+or\s+/).map do |word|
        case word
        when "end-of-input", "$end"
          "end-of-input"
        when /^keyword\_/
          "「#{word.sub("keyword_", "")}」"
        when "'\\n'"
          "改行"
        when /^'[^']+'$/
          "「 #{word.gsub("'", "")} 」"
        else
          word
        end
      end
    end
    
    def get_keywords_from_script(keywords)
      keywords.select { |keyword| @script.index(keyword) }
    end
    
    def name_error_inspect(ret)
      ret = ret.lines.first + ret.lines.last
      if @exception.name.to_s.encode("UTF-8") == "　"
        @range = default_range
        ret += "スクリプト中に全角空白が混じっています。"
      else
        ret += "#{@exception.is_a?(NoMethodError) ? "" : "変数/"}メソッド"
        ret += "「\e[31m\e[4m#{@exception.name}\e[0m」は存在しません。"
        if @did_you_mean
          did_you_mean = @did_you_mean.map{|d| "\e[33m#{d}\e[0m"}.join(" / ")
          ret += "「#{did_you_mean}」の入力ミスではありませんか？"
        end
      end
      return ret
    end
  end
  
  set_eturem_class Ja
end

require "eturem"

