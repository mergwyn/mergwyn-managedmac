# @summary
#   Simple class for activating or deactivating OS X logouthooks and specifying
#   a directory of scripts to execute at login time.
#
# @note
#   How does it work?
#
#   Employs Managedmac::Hook defined type to create a master logouthook.
#       /etc/masterhooks/logouthook.rb
#   It then activates the hook by setting the LoginHook key in the root
#   com.apple.loginwindow preferences domain.
#
#   Once the hook is activated, each time a user logs in, the scripts directory
#   you specify will be searched for executables. From this discovery, a list
#   of child executables is created. The Master hook will then iterate over this
#   list, executing each file in turn.
#
#   The files are executed in alpha-numeric order.
#
# @note
#   While setting enable => true will create the script dir if it doesn't
#   already exist, setting enable => false will NOT remove directory as it is not
#   strictly managed. Removal of orphaned scripts is an excercise left up to the
#   administrator.
#
# @param enable
#   Whether to active the master logouthook or not.
#
# @param scripts
#   An absolute path on the local machine that will store the scripts you want
#   executed by the master logouthook. Optional parameter.
#
# @example defaults.yaml
#     ---
#     managedmac::logouthook::enable: true
#     managedmac::logouthook::scripts: /path/to/your/scripts
#
# @example my_manifest.pp
#     include managedmac::logouthook
#
# @example Simple class
#     class { 'managedmac::logouthook':
#        enable  => true,
#        scripts => '/path/to/your/scripts',
#     }
#
class managedmac::logouthook (
  Optional[Boolean] $enable               = undef,
  Optional[Stdlib::Absolutepath] $scripts = undef,
) {

  unless $enable == undef {
    managedmac::hook {'logout':
      enable  => $enable,
      scripts => $scripts,
    }
  }

}
