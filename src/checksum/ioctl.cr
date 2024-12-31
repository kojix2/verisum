{% if flag?(:unix) %}
  lib LibC
    struct Winsize
      ws_row : UInt16
      ws_col : UInt16
      ws_xpixel : UInt16
      ws_ypixel : UInt16
    end

    TIOCGWINSZ = 0x5413
    fun ioctl(fd : Int32, request : UInt32, ws : Pointer(Winsize)) : Int32
  end
{% end %}

module CheckSum
  # Returns the width of the terminal screen.
  # It first checks the `COLUMNS` environment variable.
  # If not set, it defaults to `80`.
  private def self.default_screen_width : Int32
    ENV.fetch("COLUMNS", 80).to_i
  end

  # Returns the width of the terminal screen.
  # - On Unix systems, it uses the `ioctl` system call to get the screen width.
  # - On other systems, it checks the `COLUMNS` environment variable.
  #   - If not set, it defaults to `80`.

  {% if flag?(:unix) %}
    def self.screen_width : Int32
      ws = LibC::Winsize.new
      fd = STDOUT.fd

      if LibC.ioctl(fd, LibC::TIOCGWINSZ, pointerof(ws)) == 0
        ws.ws_col.to_i32
      else
        default_screen_width
      end
    end
  {% else %}
    def self.screen_width : Int32
      default_screen_width
    end
  {% end %}
end
