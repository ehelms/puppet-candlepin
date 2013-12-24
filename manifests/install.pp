# Candlepin installation
class candlepin::install {
  package {['candlepin', "candlepin-${candlepin::tomcat}"]:
    ensure => 'installed'
  }
}
