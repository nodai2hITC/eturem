require "eturem/base"
require "eturem/version"

begin
  load $0
rescue Exception => exception
  exit if exception.is_a? SystemExit
  Eturem.output_error(exception, File.absolute_path(__FILE__))
end

exit
