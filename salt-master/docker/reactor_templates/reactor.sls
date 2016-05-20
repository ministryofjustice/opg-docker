create_file:
  local.file.touch:
    tgt: '*'
    arg:
      - '/tmp/foo'
