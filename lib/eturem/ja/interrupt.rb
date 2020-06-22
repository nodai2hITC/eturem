# coding: utf-8

module Eturem
  module InterruptExt
    include ExceptionExt

    def eturem_message()
      @eturem_message_ja = "プログラムが途中で強制終了されました。"
      super
    end
  end
end
