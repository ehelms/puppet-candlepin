# Candlepin installation
class candlepin::install {
  package {['candlepin', "candlepin-${candlepin::params::tomcat}"]:
    ensure => 'installed'
  }
}
