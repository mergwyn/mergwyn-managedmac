# @summary
#   Module initializer.
#
# @example
#  include managedmac
#
#  class { managedmac: }
#
class managedmac {

  if $facts['os']['family'] != 'Darwin' {
    fail("unsupported osfamily: ${facts['os']['family']}")
  }

  $min_os_version = '11.0'

  if version_compare($facts['os']['version']['major'], $min_os_version) < 0 {
    fail("unsupported product version: ${facts['os']['version']['major']}")
  }

  include managedmac::ntp
  include managedmac::activedirectory
  #include managedmac::security
  include managedmac::desktop
  include managedmac::mcx
  include managedmac::filevault
  include managedmac::loginwindow
  include managedmac::softwareupdate
  include managedmac::energysaver
  #include managedmac::portablehomes
  #include managedmac::mounts
  include managedmac::loginhook
  include managedmac::logouthook
  #include managedmac::sshd
  #include managedmac::remotemanagement
  #include managedmac::screensharing
  #include managedmac::mobileconfigs
  #include managedmac::propertylists
  include managedmac::execs
  include managedmac::files
  #include managedmac::users
  include managedmac::groups
  include managedmac::cron

}
