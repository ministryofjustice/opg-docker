create_file:
  local.cmd.run:
    tgt: '*'
    arg:
      - 'touch /tmp/foo'
