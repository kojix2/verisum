module CheckSum
  class App
    module Utils
      private def resolve_filepath(filename)
        if filename == "-"
          if File.exists?("-")
            stderr.puts "[checksum] File “-” exists. Read #{File.expand_path(filename)} instead of standard input"
          else # stdin
            return "-"
          end
        end
        option.absolute_path? ? File.expand_path(filename) : filename
      end

      private def format_time_span(span : Time::Span)
        total_seconds = span.total_seconds
        if total_seconds < 60
          return "#{total_seconds.round(2)} seconds"
        end

        minutes = span.total_minutes
        seconds = span.seconds
        "#{"%d" % minutes.floor}:#{seconds < 10 ? "0" : ""}#{seconds} minutes"
      end

      def remove_bom(line : String) : String
        b = {"\xEF\xBB\xBF", "\xFE\xFF", "\xFF\xFE", "\x00\x00\xFE\xFF", "\xFF\xFE\x00\x00"}.find do |bom|
          line.starts_with?(bom)
        end
        b ? line[b.size..-1] : line
      end
    end
  end
end
