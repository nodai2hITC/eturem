module Eturem
  module SyntaxErrorExt
    include ExceptionExt

    def eturem_message()
      if @eturem_message.match(/unexpected (?<unexpected>(?:','|[^,])+)/)
        eturem_unexpected(eturem_transform_keyword(Regexp.last_match(:unexpected)))
      elsif @eturem_message.match(/Invalid (?<invalid>(?:break|next|retry|redo|yield))/)
        eturem_invalid(Regexp.last_match(:invalid))
      elsif @eturem_message.include?("unterminated string meets end of file")
        eturem_unterminated_string
      elsif @eturem_message.include?("unterminated regexp meets end of file")
        eturem_unterminated_regexp
      end
      super
    end

    def eturem_unexpected(unexpected)
      expecting = ["ファイルの末尾"]
      if @eturem_message.match(/[,\s]expecting (?<expecting>.+)/)
        expecting = Regexp.last_match(:expecting).split(" or ").map do |exp|
          eturem_transform_keyword(exp)
        end
      end
      Eturem::Base.highlight(@eturem_script_lines[@eturem_lineno], unexpected, "\e[1;4;31m")

      keywords = %w[if unless case while until for begin def class module do].select do |keyword|
        @eturem_script_lines.join.include?(keyword)
      end
      keywords = "「#{keywords.join(" / ")}」"
      keywords = "ifなど" if keywords == "「」"
      if unexpected == "ファイルの末尾"
        @eturem_message_ja =
          "（ただし、実際のエラーの原因はおそらく#{@eturem_lineno}行目より前にあります。）\n"
        if expecting.join == "ファイルの末尾"
          @eturem_message_ja += "構文エラーです。何か足りないものがあるようです。"
        else
          @eturem_message_ja += "構文エラーです。 #{expecting.join(" または ")} が足りない可能性があります。"
        end
        if expecting.include?("end")
          @eturem_message_ja += "#{keywords}に対応する「end」があるか確認してください。"
        end
      elsif expecting.join == "ファイルの末尾"
        @eturem_message_ja =
          "構文エラーです。予期せぬ #{unexpected} があります。以下のような可能性があります。\n" +
          "・その直前に何らかのエラーの原因がある。\n" +
          "・#{unexpected} が余分に書かれている、またはタイプミスで予期せず書いてしまった。"
        if unexpected == "end"
          @eturem_message_ja += "\n・#{keywords}と「end」の対応が合っていない。"
        end
      elsif !expecting.empty?
        @eturem_message_ja =
          "構文エラーです。 #{expecting.join(" または ")} が来るべき場所に、" +
          "#{unexpected} が来てしまいました。"
      end
    end

    def eturem_invalid(invalid)
      Eturem::Base.highlight(@eturem_script_lines[@eturem_lineno], invalid, "\e[1;4;31m")
      @eturem_message_ja = "#{invalid} が不適切な場所にあります。"
    end

    def eturem_unterminated_string()
      @eturem_message_ja = "文字列が閉じられていません。「\"」や「'」を確認してください。"
    end

    def eturem_unterminated_regexp()
      @eturem_message_ja = "正規表現が閉じられていません。「/」を確認してください。"
    end

    def eturem_transform_keyword(keyword)
      case keyword
      when "end-of-input", "$end"
        "ファイルの末尾"
      when /^(?:keyword|modifier)_/
        Regexp.last_match.post_match
      when "'\\n'"
        "改行"
      when "backslash"
        "\\"
      when /^[`']([^']+)'$/
        $1
      else
        keyword
      end
    end
  end
end
