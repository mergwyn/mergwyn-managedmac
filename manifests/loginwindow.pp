# @summary
#   Controls various OS X Loginwindow options spanning multiple preference
#   domains and resource types.
#
# @note
#   This is not a full implementation of the available controls. Many
#   OpenDirectory related controls were removed becuase they were either no
#   longer supported in OS X, cumbersome or out of scope.
#
# @param users
#   A list of user names allowed to access the machine via the loginwindow.
#   This control is implemented in the com.apple.access_loginwindow ACL
#   group. By default, this group does not exist.
#
# @param groups
#   A list of groups (names or GUIDs) allowed to access the machine via the
#   loginwindow. This control is implemented in the
#   com.apple.access_loginwindow ACL group. By default, this group does not
#   exist.
#
# @param strict
#   How to handle membership in the users and nestedgroups arrays. Informs the
#   provider whether to merge the specified members into the record, or replace
#   them outright. See the Macgroup documentation for details.
#
# @param allow_list
#   A list of GUIDs corresponding to allowed users or groups.
#   Corresponds to the AllowList key.
#
# @param deny_list
#   A list of GUIDs corresponding to denied users or groups.
#   Corresponds to the DenyList key.
#
# @param disable_console_access
#   Users can access the OS X console by entering the special username:
#   '> console'. Setting this to true will disable this feature.
#   Corresponds to the DisableConsoleAccess key.
#
# @param enable_external_accounts
#   Enable the external accounts feature that allows users to store their home
#   directory and account information on a removable disk.
#   Corresponds to the EnableExternalAccounts key.
#
# @param hide_admin_users
#   Hide administrator accounts when displaying accounts at the loginwindow.
#   Corresponds to the HideAdminUsers key.
#
# @param hide_local_users
#   Hide local user accounts when displaying accounts at the loginwindow.
#   Corresponds to the HideLocalUsers key.
#
# @param hide_mobile_accounts
#   Hide mobile user accounts when displaying accounts at the loginwindow.
#   Corresponds to the HideMobileAccounts key.
#
# @param show_network_users
#   Include network user accounts when displaying accounts at the loginwindow.
#   Corresponds to the IncludeNetworkUser key.
#
# @param allow_local_only_users
#   Allow local-only account users to login.
#   Corresponds to the LocalUserLoginEnabled key.
#
# @param loginwindow_text
#   Specifies a message to post on the loginwindow.
#   Corresponds to the LoginwindowText key.
#
# @param restart_disabled
#   Disable/Remove the Restart button from the loginwindow.
#   Corresponds to the RestartDisabled key.
#
# @param shutdown_disabled
#   Disable/Remove the Shutdown button from the loginwindow.
#   Corresponds to the ShutDownDisabled key.
#
# @param sleep_disabled
#   Disable/Remove the Sleep button from the loginwindow.
#   Corresponds to the SleepDisabled key.
#
# @param retries_until_hint
#   The number of failed login attempts a user gets until they are given a
#   password hint.
#   Corresponds to the RetriesUntilHint key.
#
# @param show_name_and_password_fields
#   Use the name and password fields rather than display each account at the
#   loginwindow. Setting this to true will override many other related keys.
#   Corresponds to the SHOWFULLNAME key.
#
# @param show_other_button
#   Show the "Other" button when displaying accounts at the loginwindow.
#   Corresponds to the SHOWOTHERUSERS_MANAGED key.
#
# @param disable_autologin
#   Disable the use of the OS X autologin feature.
#   Corresponds to the com.apple.login.mcx.DisableAutoLoginClient key.
#
# @param disable_guest_account
#   Disable the the OS X Guest login feature.
#
# @param auto_logout_delay
#   Forces a logout after the machine is idle for n seconds.
#
# @param enable_fast_user_switching
#   Enable or disable Fast User Switching.
#
# @param disable_fde_autologin
#   Disable autologin after FileVault EFI is unlocked.
#
# @param adminhostinfo
#   Show System Info, HostName, OS Version and IP Address
#   at Login Screen using alt + click on the clock.
#       Suggested Value: HostName
#
# @example  defaults.yaml
#      ---
#      managedmac::loginwindow::users:
#         - fry
#         - bender
#      managedmac::loginwindow::groups:
#         - robothouse
#         - 20EFB92F-4842-4218-8973-9F4738963660
#      managedmac::loginwindow::allow_list:
#         - D2C2107F-CE19-4C9F-9235-688BEB01D8C0
#         - 779A91D0-885B-4066-97FC-BEECB737E6AF
#      managedmac::loginwindow::deny_list:
#         - C3F27BC2-8F89-4D56-9525-95B5133D8F25
#         - F1A496E4-86EB-4387-A4D6-5D6FAD9201E7
#      managedmac::loginwindow::disable_console_access: true
#      managedmac::loginwindow::enable_external_accounts: false
#      managedmac::loginwindow::hide_admin_users: false
#      managedmac::loginwindow::hide_local_users: false
#      managedmac::loginwindow::hide_mobile_accounts: false
#      managedmac::loginwindow::show_network_users: false
#      managedmac::loginwindow::allow_local_only_users: true
#      managedmac::loginwindow::loginwindow_text: "Some message..."
#      managedmac::loginwindow::restart_disabled: false
#      managedmac::loginwindow::retries_until_hint: 1000000
#      managedmac::loginwindow::show_name_and_password_fields: true
#      managedmac::loginwindow::show_other_button: false
#      managedmac::loginwindow::shutdown_disabled: false
#      managedmac::loginwindow::sleep_disabled: false
#      managedmac::loginwindow::disable_autologin: true
#      managedmac::loginwindow::disable_guest_account: true
#      managedmac::loginwindow::auto_logout_delay: 3600
#      managedmac::loginwindow::enable_fast_user_switching: false
#      managedmac::loginwindow::disable_fde_autologin: true
#      managedmac::loginwindow::adminhostinfo: HostName
#    
# @example my_manifest.pp
#      include managedmac::loginwindow
#    
# @example simple class
#      class { 'managedmac::loginwindow':
#        loginwindow_text => 'Planet Express Employees Only',
#        disable_console_access => true,
#        show_name_and_password_fields => true,
#      }
#
class managedmac::loginwindow (
  Array[String] $users                             = [],
  Array[String] $groups                            = [],
  Boolean $strict                                  = true,
  Optional[String] $adminhostinfo                  = undef,
  Array[String] $allow_list                        = [],
  Array[String] $deny_list                         = [],
  Optional[Boolean] $disable_console_access        = undef,
  Optional[Boolean] $enable_external_accounts      = undef,
  Optional[Boolean] $hide_admin_users              = undef,
  Optional[Boolean] $hide_local_users              = undef,
  Optional[Boolean] $hide_mobile_accounts          = undef,
  Optional[Boolean] $show_network_users            = undef,
  Optional[Boolean] $allow_local_only_users        = undef,
  Optional[String] $loginwindow_text               = undef,
  Optional[Boolean] $restart_disabled              = undef,
  Optional[Boolean] $shutdown_disabled             = undef,
  Optional[Boolean] $sleep_disabled                = undef,
  Optional[Integer] $retries_until_hint            = undef,
  Optional[Boolean] $show_name_and_password_fields = undef,
  Optional[Boolean] $show_other_button             = undef,
  Optional[Boolean] $disable_autologin             = undef,
  Optional[Boolean] $disable_guest_account         = undef,
  Optional[Integer] $auto_logout_delay             = undef,
  Optional[Boolean] $enable_fast_user_switching    = undef,
  Optional[Boolean] $disable_fde_autologin         = undef,
) {

  $params = {
    'com.apple.loginwindow' => {
      'AdminHostInfo'                              => $adminhostinfo,
      'AllowList'                                  => $allow_list,
      'DenyList'                                   => $deny_list,
      'DisableConsoleAccess'                       =>
        $disable_console_access,
      'EnableExternalAccounts'                     =>
        $enable_external_accounts,
      'HideAdminUsers'                             => $hide_admin_users,
      'HideLocalUsers'                             => $hide_local_users,
      'HideMobileAccounts'                         => $hide_mobile_accounts,
      'IncludeNetworkUser'                         => $show_network_users,
      'LocalUserLoginEnabled'                      => $allow_local_only_users,
      'LoginwindowText'                            => $loginwindow_text,
      'RestartDisabled'                            => $restart_disabled,
      'ShutDownDisabled'                           => $shutdown_disabled,
      'SleepDisabled'                              => $sleep_disabled,
      'RetriesUntilHint'                           => $retries_until_hint,
      'SHOWFULLNAME'                               =>
        $show_name_and_password_fields,
      'SHOWOTHERUSERS_MANAGED'                     => $show_other_button,
      'com.apple.login.mcx.DisableAutoLoginClient' => $disable_autologin,
      'DisableFDEAutoLogin'                        => $disable_fde_autologin,
    },
    'com.apple.MCX' => {
      'DisableGuestAccount' => $disable_guest_account,
      'EnableGuestAccount'  => $disable_guest_account ? {
        undef => undef,
        true  => false,
        false => true,
      },
    },
    '.GlobalPreferences' => {
      'com.apple.autologout.AutoLogOutDelay' => $auto_logout_delay,
      'MultipleSessionEnabled'               => $enable_fast_user_switching,
    },
  }

  # Should return Array
  $content = process_mobileconfig_params($params)

  $mobileconfig_ensure = empty($content) ? {
    true  => 'absent',
    false => 'present',
  }

  $acl_inactive = empty($users) and empty($groups)

  $acl_ensure = $acl_inactive ? {
    true  => absent,
    false => present,
  }

  macgroup { 'com.apple.access_loginwindow':
    ensure       => $acl_ensure,
    users        => $users,
    nestedgroups => $groups,
    strict       => $strict,
  }

  $organization = hiera('managedmac::organization', 'SFU')

  mobileconfig { 'managedmac.loginwindow.alacarte':
    ensure       => $mobileconfig_ensure,
    displayname  => 'Managed Mac: Loginwindow',
    description  => 'Loginwindow configuration. Installed by Puppet.',
    organization => $organization,
    content      => $content,
  }

}
