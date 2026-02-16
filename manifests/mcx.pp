# @summary
# Leverages the Puppet MCX type to deploy some options not available in
# Configuration Profiles.
#
# @note If any parameters are defined:
#   - Creates a new computer record in the DSLocal node, "mcx_puppet"
#   - Applies the specified settings to the new computer record
#
# @param bluetooth
#   Enable or disable Bluetooth power and administrative controls.
#   Accepts values: on/off, true/false, enable/disable. Values are enforced, so
#   if you set it to on/true/enable, users will not be able to turn off the
#   service.
#
# @param wifi
#   Enable or disable Airport power and administrative controls.  Accepts
#   values: on/off, true/false, enable/disable. Values are enforced, so if you
#   set it to on/true/enable, users will not be able to turn off the service.
#
# @param loginitems
#   Accepts a list of items you want launched at login time. 
#
# @param suppress_icloud_setup
#   Suppress iCloud Setup dialogue for new users.
#
# @param hidden_preference_panes
#   A list of hidden System Preferences panes. Prefernce pane names MUST be
#   specified by their reverse domain ID. (Eg. com.apple.preferences.icloud)
#
# @example defaults.yaml
#      ---
#      managedmac::mcx::bluetooth: on
#      managedmac::mcx::wifi: off
#      managedmac::mcx::loginitems:
#         - /Applications/Chess.app
#      managedmac::mcx::suppress_icloud_setup: true
#      managedmac::mcx::hidden_preference_panes:
#         - com.apple.preferences.icloud
#    
# @example my_manifest.pp
#      include managedmac::mcx
#    
# @example Basic class
#     class { 'managedmac::mcx':
#       bluetooth   => on,
#       wifi        => off,
#       loginitems  => ['/path/to/some/file'],
#     }
#
class managedmac::mcx (
  Optional[Managedmac::Universalonoff] $bluetooth = undef,
  Optional[Managedmac::Universalonoff] $wifi      = undef,
  Array[Stdlib::Absolutepath] $loginitems         = [],
  Optional[Boolean] $suppress_icloud_setup        = undef,
  Array[Stdlib::Fqdn] $hidden_preference_panes    = [],
){

  $bluetooth_state = $bluetooth ? {
    /on|true|enable/    => false,
    true                => false,
    /off|false|disable/ => true,
    false               => true,
    undef               => undef,
    default             => fail("Parameter Error: invalid value for :bluetooth, ${bluetooth}"),
  }

  $wifi_state = $wifi ? {
    /on|true|enable/    => false,
    true                => false,
    /off|false|disable/ => true,
    false               => true,
    undef               => undef,
    default             => fail("Parameter Error: invalid value for :wifi, ${wifi}"),
  }

  $content = process_mcx_options($bluetooth_state,
    $wifi_state, $loginitems, $suppress_icloud_setup, $hidden_preference_panes)

  $ensure = empty($content) ? {
    true    => absent,
    default => present,
  }

  $organization = hiera('managedmac::organization', 'SFU')

  mobileconfig { 'managedmac.mcx.alacarte':
    ensure       => $ensure,
    content      => $content,
    description  => 'Custom MCX Settings',
    displayname  => 'Managed Mac: Custom MCX',
    organization => $organization,
    #TODO confirm removal of this value
    #removaldisallowed => false,
  }

}
