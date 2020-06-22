# coding: utf-8

module Eturem
  module LoadErrorExt
    include ExceptionExt

    def eturem_message()
      @eturem_message_ja =
        %<ファイル/ライブラリ "#{self.path.encode("utf-8")}" が見つかりません。> +
        %<ファイル/ライブラリ名を確認してください。>
      super
    end
  end
end
