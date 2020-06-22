module Eturem
  module NameErrorExt
    include ExceptionExt

    def eturem_message()
      if self.name.to_s.encode("utf-8").include?("　")
        eturem_multibyte_space
      elsif self.name.to_s.encode("utf-8").match(/[”’｀（）｛｝＃]/)
        eturem_multibyte_char
      elsif self.receiver == nil
        eturem_receiver_is_nil
      else
        eturem_basic_name_error
      end
      super
    end

    def eturem_multibyte_space
      @eturem_script_lines = Eturem::Base.read_script(@eturem_path)
      Eturem::Base.highlight(@eturem_script_lines[@eturem_lineno], /　+/, "\e[1;4;31m")
      @eturem_message_ja = "スクリプト中に全角空白が混じっています。"
    end

    def eturem_multibyte_char
      @eturem_script_lines = Eturem::Base.read_script(@eturem_path)
      if @eturem_script_lines[@eturem_lineno]
        @eturem_script_lines[@eturem_lineno].gsub!(/[”’｀（）＃]+/){ "\e[1;4;31m#{$&}\e[0m" }
      end
      @eturem_message_ja = "スクリプト中に全角記号が混じっています。"
    end

    def eturem_receiver_is_nil
      @eturem_message_ja =
      "nil に対して #{self.name.to_s.encode("utf-8")} というメソッドを呼び出そうとしています。\n" +
      "変数の値/メソッドの返値が予期せず nil になっている可能性があります。"
    end

    def eturem_basic_name_error
      @eturem_message_ja =
        (self.is_a?(NoMethodError) ? "メソッド" : "変数/メソッド") +
        "「\e[1;4;31m#{self.name.to_s.encode("utf-8")}\e[0m」は存在しません。"
      unless @eturem_corrections.empty?
        did_you_mean = @eturem_corrections.map{ |d|
          "\e[1;33m#{d.to_s.encode("utf-8")}\e[0m"
        }.join(" / ")
        @eturem_message_ja += "「#{did_you_mean}」の入力ミスではありませんか？"
      end
    end
  end
end
