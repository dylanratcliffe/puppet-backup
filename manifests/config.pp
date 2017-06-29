# Global config for backup resources
#
# This class allows us to set a global loctaion for the backup directory and to
# ensure that it exists
#
# @summary Sets global defaults for the `backup` type
#
# @example Set and manage a backup dir
#   class { '::backup::config':
#     backup_dir        => 'C:/backups',
#     manage_backup_dir => true,
#   }
#
# @param backup_dir Where to put the backups
# @param manage_backup_dir Actually manage the directory or not
class backup::config (
  Stdlib::Absolutepath $backup_dir        = $::backups::params::backup_dir,
  Boolean              $manage_backup_dir = true,
) inherits backup::params {
  if $manage_backup_dir {
    ensure_resource('file',$backup_dir,{'ensure' => 'directory'})
  }
}
