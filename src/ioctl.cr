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

  def screen_width
    ws = LibC::Winsize.new
    fd = STDOUT.fd

    if LibC.ioctl(fd, LibC::TIOCGWINSZ, pointerof(ws)) == 0
      ws.ws_col.to_i32
    else
      begin
        ENV.fetch("COLUMNS", 80).to_i
      rescue
        80
      end
    end
  end
{% else %}
  def screen_width : Int32
    begin
      ENV.fetch("COLUMNS", 80).to_i
    rescue
      80
    end
  end
{% end %}
