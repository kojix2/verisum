module CheckSum
  class App
    class CheckResult
      property total : UInt64 = 0
      property success : UInt64 = 0
      property mismatch : UInt64 = 0
      property error : UInt64 = 0

      def initialize(@total = 0, @success = 0, @mismatch = 0, @error = 0)
      end

      def to_h
        {total:    total,
         success:  success,
         mismatch: mismatch,
         error:    error}
      end

      def to_s
        String.build do |str|
          str << "#{total} files, "
          str << format_status("success", success, :green)
          str << ", "
          str << format_status("mismatch", mismatch, :red)
          str << ", "
          str << format_status("errors", error, :magenta)
        end
      end

      private def format_status(label, count, color)
        count.zero? ? "#{count} #{label}" : "#{count} #{label}".colorize(color).to_s
      end

      def ==(other : self)
        (self.total == other.total) &&
          (self.success == other.success) &&
          (self.mismatch == other.mismatch) &&
          (self.error == other.error)
      end
    end
  end
end
