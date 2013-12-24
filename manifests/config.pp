# Configuration for Candlepin
class candlepin::config {
  include certs

  user { 'tomcat':
    ensure => present,
    groups => $candlepin::user_groups,
    before => Service[$candlepin::tomcat]
  }

  file { "/usr/share/${candlepin::tomcat}/conf/keystore":
    ensure  => link,
    target  => $certs::keystore,
    require => File[$certs::keystore],
    before  => Service[$candlepin::tomcat],
  }

  file {
    '/etc/candlepin/candlepin.conf':
      ensure  => file,
      content => template('candlepin/etc/candlepin/candlepin.conf.erb'),
      mode    => '0600',
      owner   => 'tomcat',
      notify  => Service[$candlepin::tomcat];

    "/etc/${candlepin::tomcat}/server.xml":
      ensure  => file,
      content => template("candlepin/etc/${candlepin::tomcat}/server.xml.erb"),
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      notify  => Service[$candlepin::tomcat];

    # various tomcat versions had some permission bugs - fix them all
    "/etc/${candlepin::tomcat}":
      mode    => '0775';

    "/var/log/${candlepin::tomcat}":
      ensure  => directory,
      mode    => '0775',
      owner   => 'root',
      group   => 'tomcat';

    '/var/log/candlepin':
      ensure  => directory,
      mode    => '0775',
      owner   => 'tomcat',
      group   => 'tomcat';

    "/var/lib/${candlepin::tomcat}":
      ensure  => directory,
      mode    => '0775',
      owner   => 'tomcat',
      group   => 'tomcat';

    "/var/cache/${candlepin::tomcat}":
      ensure  => directory,
      mode    => '0775',
      owner   => 'tomcat',
      group   => 'tomcat';
  }

  if $candlepin::params::reset_data == 'YES' {
    exec { 'reset_candlepin_db':
      command => "rm -f ${candlepin::log_dir}/cpdb_done; rm -f ${candlepin::log_dir}/cpinit_done; service ${candlepin::tomcat} stop; test 1 -eq 1",
      path    => '/sbin:/bin:/usr/bin',
      before  => Exec['cpdb'],
      notify  => Postgresql::Dropdb[$candlepin::db_name],
    }
    postgresql::dropdb {$candlepin::db_name:
      logfile     => "${candlepin::log_dir}/drop-postgresql-candlepin-database.log",
      require     => [ Postgresql::Createuser[$candlepin::db_user], File[$candlepin::log_dir] ],
      before      => Exec['cpdb'],
      refreshonly => true,
      notify      => [
        Exec['cpdb'],
        Exec['cpinit'],
      ],
    }
  }

}
