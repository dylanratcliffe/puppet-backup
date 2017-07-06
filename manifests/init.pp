# A backed up file.
#
# The defined type causes puppet to back up a file before it changes it. This
# functionality is different to that of the Filebucket in that it can back up
# files regardless of the type of resource that is changing them. Filebucket on
# the other hand onlt works with `file` resources. The functionality tha this
# provides is implemented by the `puppetlabs/transition` module which allows
# puppet to modify the state of one resource before it goes to change another.
# In this case is creates a backup if a given file, before changing the
# `$backup_before` resource or class.
#
# This defined type also supports restoring files from a backup. Simply set
# `ensure` to `restored` and the file will copied from the backup directory.
# Please not that this may cause duplicate declaration or loops where Puppet
# restored the file then changes it again. You will likely need to comment out
# the class that caused the arroneous change to get this to work properly.
#
# @summary Backs up files before changing them, even if you don't know how they
#   get changed.
#
# @example Backing up ssh config
#   backup { '/etc/ssh/sshd_config':
#     ensure        => 'backed_up',
#     backup_before => Class['::sshd'],
#   }
#
# @example Backing up ssh config to a specific location
#   backup { '/etc/ssh/sshd_config':
#     ensure        => 'backed_up',
#     backup_before => Class['::sshd'],
#     backup_dir    => '/var/backups',
#   }
#
# @param backup_before The resource or class which changes the file
# @param backup_dir Where to put the backups
# @param file The file to back up
# @param ensure `backed_up` or `restored`
# @version An optional version to append
define backup (
  Type[Catalogentry]             $watch,
  Backup::Dir                    $backup_dir = 'relative',
  Stdlib::Absolutepath           $file       = $title,
  Enum['backed_up','restored']   $ensure     = 'backed_up',
  Optional[String]               $version    = undef,
) {
  # Convert class reference to resource references
  $backup_before = $watch.get_resources

  if $backup_dir == 'relative' {
    # If it is a relative directory we need to change the way some things work
    $_backup_dir = $file.dirname
    $backup_file_location = "${_backup_dir}/${file.basename}"
  } else {
    $_backup_dir = $backup_dir

    # Replace slashes in the file name with underscores to make it safe
    $escaped_file = regsubst($file,/[\\\/]/, '_', 'G')
    $backup_file_location = "${_backup_dir}/${escaped_file}"
  }

  # If we are specifying a version then we don't want to replace those versions
  # once they have been created. This requires different parameters
  if $version {
    $replace     = false
    $backup_path = "${backup_file_location}_${version}"
  } else {
    $replace     = true
    $backup_path = "${backup_file_location}_previous"
  }

  if $ensure == 'backed_up' {
    file { 'backup_file':
      ensure => file,
      path   => "${backup_file_location}_previous",
    }

    transition { "backup ${file}":
      resource   => File['backup_file'],
      attributes => {
        source             => $file,
        source_permissions => 'use',
        replace            => $replace,
        path               => $backup_path,
      },
      prior_to   => $backup_before,
    }
  } elsif $ensure == 'restored' {
    file { $file:
      ensure => file,
      source => $backup_path,
    }
  }
}
