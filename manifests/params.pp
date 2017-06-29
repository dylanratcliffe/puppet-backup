# Calculates defaults
class backup::params {
  $backup_dir = $::kernel ? {
    'windows' => 'C:/Windows/Temp',
    default   => '/var/tmp'
  }
}
