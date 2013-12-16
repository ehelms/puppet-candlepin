class candlepin {
  Exec { logoutput => true, timeout => 0 }

  include postgresql
  include candlepin::params
  include candlepin::config
  include candlepin::service
  include certs::params
}
