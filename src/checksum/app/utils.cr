module CheckSum
  class App
    private def format_file_number(index, total)
      total_digits = total.to_s.size
      formatted_index = (index + 1).to_s.rjust(total_digits, ' ')
      "(#{formatted_index}/#{total}) "
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
  end
end
