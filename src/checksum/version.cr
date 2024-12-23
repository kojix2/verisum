module CheckSum
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
  SOURCE  = "https://github.com/kojix2/checksum.cr"
  # SOURCE  = {{ `git remote get-url origin`.chomp.stringify }}
end
