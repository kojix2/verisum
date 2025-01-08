module CheckSum
  class App
    class CheckResult
      property total : UInt64 = 0
      property pass : UInt64 = 0
      property mismatch : UInt64 = 0
      property error : UInt64 = 0

      def initialize(@total = 0, @pass = 0, @mismatch = 0, @error = 0)
      end

      def to_h
        {total:    total,
         pass:  pass,
         mismatch: mismatch,
         error:    error}
      end

      def to_s(io) : Nil
        io << "#{total} #{total == 1 ? "file" : "files"}, "
        io << format_status("pass", "passes", pass, :green)
        io << ", "
        io << format_status("mismatch", "mismatches", mismatch, :red)
        io << ", "
        io << format_status("error", "errors", error, :magenta)
      end

      private def format_status(singular, plural, count, color)
        label = count == 1 ? singular : plural
        count.zero? ? "#{count} #{label}" : "#{count} #{label}".colorize(color).to_s
      end

      def ==(other : self)
        (self.total == other.total) &&
          (self.pass == other.pass) &&
          (self.mismatch == other.mismatch) &&
          (self.error == other.error)
      end
    end
  end
end
