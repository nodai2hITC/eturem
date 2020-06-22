module Eturem
  module SystemStackErrorExt
    include ExceptionExt

    def eturem_message()
      @eturem_message_ja = "システムスタックがあふれました。意図しない無限ループが生じている可能性があります。"
      super
    end
  end
end
