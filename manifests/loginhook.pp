# @summary
#   Simple class for activating or deactivating OS X loginhooks and specifying
#   a directory of scripts to execute at login time.
#
# @note
#   How does it work?
#
#   Employs Managedmac::Hook defined type to create a master loginhook.
#       /etc/masterhooks/loginhook.rb
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
#   While setting enalbe => true will create the script dir if it doesn't
#   already exist, setting enable => false will NOT remove directory as it is not
#   strictly managed. Removal of orphaned scripts is an excercise left up to the
#   administrator.
#
# @param enable
#   Whether to active the master loginhook or not.
#
# @param scripts
#   An absolute path on the local machine that will store the scripts you want
#   executed by the master loginhook. Optional parameter.
#
# @example defaults.yaml
#     ---
#     managedmac::loginhook::enable: true
#     managedmac::loginhook::scripts: /path/to/your/scripts
#    
# @example my_manifest.pp
#     include managedmac::loginhook
#    
class managedmac::loginhook (
  Optional[Boolean] $enable               = undef,
  Optional[Stdlib::Absolutepath] $scripts = undef,
) {

  unless $enable == undef {
    managedmac::hook {'login':
      enable  => $enable,
      scripts => $scripts,
    }
  }

}
