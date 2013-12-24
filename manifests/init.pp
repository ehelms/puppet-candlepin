# == Class: candlepin
#
# Install and configure candlepin
#
# === Parameters:
#
# $oauth_key::              The oauth key for talking to the candlepin API;
#                           default 'candlepin'
#
# $oauth_secret::           The oauth secret for talking to the candlepin API;
#                           default 'candlepin'
#
# $db_name::                The name of the Candlepin database;
#                           default 'candlepin'
#
# $db_user::                The Candlepin database username;
#                           default 'candlepin'
#
# $db_pass::                The Candlepin database password;
#                           default 'candlepin'
#
# $tomcat::                 The system tomcat to use, tomcat6 on RHEL6 and tomcat on most Fedoras
#
# $crl_file::               The Certificate Revocation File for Candlepin
#
# $user_groups::            The user groups for the Candlepin tomcat user
#
# $log_dir::                Directory for Candlepin logs;
#                           default '/var/log/candlepin'
#
# $deployment_url::         The root URL to deploy the Web and API URLs at
#
# $weburl::                 The Candlepin Web URL which is configurable via the deployment_url
#
# $apiurl::                 The Candlepin API URL which is configurable via the deployment_url
#
# $env_filtering_enabled::  default 'true'
#
# $thumbslug_enabled::      If using Thumbslug; default 'false'
#
# $thumbslug_oauth_key::    The oauth key for talking to Thumbslug
#
# $thumbslug_oauth_secret:: The oauth secret for talking to Thumbslug
#
class candlepin (

  $db_name = $candlepin::params::db_name,
  $db_user = $candlepin::params::db_user,
  $db_pass = $candlepin::params::db_pass,

  $tomcat = $candlepin::params::tomcat,

  $crl_file = $candlepin::params::crl_file,

  $user_groups = $candlepin::params::user_groups,

  $log_dir = $candlepin::params::log_dir,

  $oauth_key = $candlepin::params::oauth_key,
  $oauth_secret = $candlepin::params::oauth_secret,

  $deployment_url = $candlepin::params::deployment_url,

  $env_filtering_enabled = $candlepin::params::env_filtering_enabled,

  $thumbslug_enabled = $candlepin::params::thumbslug_enabled,
  $thumbslug_oauth_key = $candlepin::params::thumbslug_oauth_key,
  $thumbslug_oauth_secret = $candlepin::params::thumbslug_oauth_secret

  ) inherits candlepin::params {

  include certs
  include certs::config

  $keystore_password = $certs::keystore_password

  $weburl = "https://${::fqdn}/${candlepin::deployment_url}/distributors?uuid="
  $apiurl = "https://${::fqdn}/${candlepin::deployment_url}/api/distributors/"

  if $candlepin::thumbslug_enabled {
    require 'thumbslug::params'
    $thumbslug_oauth_key = 'thumbslug'
    $thumbslug_oauth_secret = $thumbslug::params::oauth_secret
    $env_filtering_enabled = false
  }

  class { 'candlepin::install': } ~>
  class { 'candlepin::config': } ~>
  class { 'candlepin::database': } ~>
  class { 'candlepin::service': } ->
  Class['candlepin']

}
