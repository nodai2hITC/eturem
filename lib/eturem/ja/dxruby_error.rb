module Eturem
  module DXRubyErrorExt
    include ExceptionExt

    def eturem_message()
      case @eturem_message
      when /^Load error - (.+)/
        @eturem_message_ja = %<ファイル "#{$1}" の読み込みに失敗しました。ファイル名を確認してください。>
      end
      super
    end
  end
end
