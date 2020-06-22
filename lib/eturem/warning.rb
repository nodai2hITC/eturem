module Warning
  def self.warn(*message)
    new_message = message.map do |mes|
      if mes.force_encoding("utf-8").match(/^(.+?):(\d+):\s*warning:\s*/)
        path, lineno, warning = $1, $2.to_i, $'.strip
        path = Eturem.program_name if path == File.expand_path(Eturem.program_name)
        str = Eturem::Base.warning_message(path, lineno, warning)
      end
      str || mes
    end
    super(*new_message)
  end
end
