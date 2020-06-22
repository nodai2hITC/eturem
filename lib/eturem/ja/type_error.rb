module Eturem
  module TypeErrorExt
    include ExceptionExt

    def eturem_message()
      @eturem_message_ja = "「#{@eturem_label}」への引数の型（種類）が正しくありません。"
      if @eturem_message.match(/no implicit conversion of (\S+) into (\S+)/)
        @eturem_message_ja += "\n本来 #{$2} 型などが来るべきところに #{$1} 型が来ています。"
      end
      super
    end
  end
end
