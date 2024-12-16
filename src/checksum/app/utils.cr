module CheckSum
  class App
    private def print_clear_the_line
      if option.clear_line?
        # restore the cursor to the last saved position
        print "\e8"
        # erase from cursor until end of screen
        print "\e[J"
        # Carriage return
        print "\r"
      else
        puts
      end
    end

    private def format_file_number(index, total)
      total_digits = total.to_s.size
      formatted_index = (index + 1).to_s.rjust(total_digits, ' ')
      "(#{formatted_index}/#{total}) "
    end
  end
end
