# coding: utf-8

module Eturem
  module Base
    def self.warning_message(path, lineno, warning)
      script_lines = Eturem::Base.read_script(path)
      script = Eturem::Base.script(script_lines, [lineno], lineno)
      "#{path}:#{lineno}: warning: #{warning}\n" + script
    end
  end
end
