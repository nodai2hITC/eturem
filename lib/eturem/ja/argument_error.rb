# coding: utf-8

module Eturem
  module ArgumentErrorExt
    include ExceptionExt

    def eturem_message()
      given = nil
      if @eturem_message.include?("wrong number of arguments")
        if @eturem_message.match(/\(given (?<given>\d+), expected (?<expected>[^)]+)\)/)
          given    = Regexp.last_match(:given).to_i
          expected = Regexp.last_match(:expected)
        elsif @eturem_message.match(/\((?<given>\d+) for (?<expected>[^)]+)\)/)
          given    = Regexp.last_match(:given).to_i
          expected = Regexp.last_match(:expected)
        end
      end

      if given
        eturem_wrong_number_of_arguments(given, expected)
      elsif @eturem_message.match(/too big/)
        eturem_argument_too_big
      else
        eturem_other_argument_error
      end
      super
    end

    def eturem_wrong_number_of_arguments(given, expected)
      @eturem_message_ja = "引数の数が正しくありません。「#{@eturem_method}」は本来"
      case expected
      when "0"
        @eturem_message_ja += "引数が不要です"
      when /^(\d+)\.\.(\d+)$/
        @eturem_message_ja += " #{$1}～#{$2} 個の引数を取ります"
      when /^(\d+)\+$/
        @eturem_message_ja += " #{$1} 個以上の引数を取ります"
      else
        @eturem_message_ja += " #{expected} 個の引数を取ります"
      end
      if given == 0
        @eturem_message_ja += "が、引数が１つも渡されていません。"
      else
        @eturem_message_ja += "が、#{given} 個の引数が渡されています。"
      end
    end

    def eturem_argument_too_big()
      @eturem_message_ja = "「#{@eturem_method}」への引数が大きすぎます。"
    end

    def eturem_other_argument_error()
      @eturem_message_ja = "「#{@eturem_method}」への引数が正しくありません。"
    end
  end
end
