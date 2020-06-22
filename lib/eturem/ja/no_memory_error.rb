# coding: utf-8

module Eturem
  module NoMemoryErrorExt
    include ExceptionExt

    def eturem_message()
      @eturem_message_ja = "メモリを確保できませんでした。あまりにも大量のデータを作成していませんか？"
      super
    end
  end
end
