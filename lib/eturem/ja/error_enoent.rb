# coding: utf-8

module Eturem
  module Errno_ENOENTExt
    include ExceptionExt

    def eturem_message()
      @eturem_message_ja = "ファイルアクセスに失敗しました。"
      if @eturem_message.match(/-\s*(?<filename>.+)\s*$/)
        filename = Regexp.last_match(:filename).encode("utf-8")
        @eturem_message_ja += %<ファイル "#{filename}" がありません。>
      else
        @eturem_message_ja += "ファイルがありません。"
      end
      @eturem_message_ja += "ファイル名を確認してください。"
      super
    end
  end
end
