module Verisum
  # Provides redirection of standard output and error streams.
  # Overrides `print` and `puts` to write to `stdout` instead of the default `STDOUT`.
  # Useful for capturing or redirecting output in tests or custom configurations.

  module Redirect
    property stdout : IO = STDOUT
    property stderr : IO = STDERR

    # Override the default output stream
    private def print(*args)
      stdout.print(*args)
    end

    # Override the default output stream
    private def puts(*args)
      stdout.puts(*args)
    end
  end
end
