module Eturem
  module ZeroDivisionErrorExt
    include ExceptionExt

    def eturem_message()
      @eturem_message_ja = "割る数が 0 での割り算はできません。"
      super
    end
  end
end
