# Backup module

*Backs up files before changing them, even if you don't know how they get changed.*

This module allows you to ensure that Puppet backs up critical files before it touches them, even if you are using a forge module to manage those files and you don't know how it actually works under the hood.

## Defined Types

`backup`

This defined type causes puppet to back up a file before it changes it. This functionality is different to that of the Filebucket in that it can back up files regardless of the type of resource that is changing them. Filebucket on the other hand only works with `file` resources. The functionality that this provides is implemented by the `puppetlabs/transition` module which allows puppet to modify the state of one resource before it goes to change another.

In this case is creates a backup of a given file, before changing the `$watch` resource or class.

This defined type also supports restoring files from a backup. Simply set `ensure` to `restored` and the file will copied from the backup directory. Please note that this may cause duplicate declaration or loops where Puppet restored the file then changes it again. You will likely need to comment out the class that caused the erroneous change to get this to work properly.

### Parameters

`watch`: The resource or class to watch. If this resource/class is going to change, a backup will be created

`backup_dir`: Where to put the backups. This defaults to `relative`, meaning that the backup file will be put in the same location as the original file, but with the version appended.

`file`: The file to back up

`ensure`: `backed_up` or `restored`

`version`: This allows you to specify a string to be assigned to the backup version. If this parameter is set, the file will be backed up once per version, the first time it is touched. This allows us to set the version to `pre_puppet` and maintain a backup of the state of the file before it was managed by Puppet. This state will not be overwritten. When restoring files the `version` parameter refers to which version to restore. If `version` is not specified, backup keeps the previous version of the file.

### Examples

#### Backing up ssh config

```puppet
backup { '/etc/ssh/sshd_config':
  ensure        => 'backed_up',
  backup_before => Class['::ssh'],
}
```

#### Backing up ssh config to a specific location

```puppet
backup { '/etc/ssh/sshd_config':
  ensure        => 'backed_up',
  backup_before => Class['::ssh'],
  backup_dir    => '/var/backups',
}
```
