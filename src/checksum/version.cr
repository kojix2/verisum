module CheckSum
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
  SOURCE  = {{ `git remote get-url origin`.chomp.stringify }}
end
