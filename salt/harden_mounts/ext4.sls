{% set uuid = salt['disk.blkid']() %}

echo {{ data['/dev/xvda2']['UUID'] }}:
  cmd.run
