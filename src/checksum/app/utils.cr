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

        if total_seconds < 10
          sprintf "%.2fs", total_seconds
        elsif total_seconds < 60
          sprintf "%.1fs", total_seconds
        elsif total_seconds < 3600
          minutes = span.minutes
          seconds = span.seconds
          String.build do |io|
            io << "#{minutes}m"
            io << " #{seconds}s" if seconds > 0
          end
        else
          hours = span.total_hours.to_i
          minutes = span.minutes
          seconds = span.seconds
          String.build do |io|
            io << "#{hours}h"
            io << " #{minutes}m" if minutes > 0
            io << " #{seconds}s" if seconds > 0
          end
        end
      end

      def remove_bom(line : String) : String
        b = {"\xEF\xBB\xBF", "\xFE\xFF", "\xFF\xFE\x00\x00", "\xFF\xFE", "\x00\x00\xFE\xFF"}.find do |bom|
          line.starts_with?(bom)
        end
        b ? line[b.size..-1] : line
      end
    end
  end
end
