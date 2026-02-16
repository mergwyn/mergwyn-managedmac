# @summary
#   Leverages the Mobileconfig type and provider to configure Energy Saver
#   settings for Desktops and Laptops.
#
# @note If no parameters are set, removal of the Mobileconfig resource is implicit.
#
# @param desktop
#   The settings to apply for Desktop machines. This is a compound parameter
#   containing the raw keys/values for configuring EnergySaver. The structure
#   is rather complex. See the examples for complete details.
#
# @param portable
#   The settings to apply for Laptop machines. This is a compound parameter
#   containing the raw keys/values for configuring EnergySaver. The structure
#   is rather complex. See the examples for complete details.
#
# @example defaults.yaml
#  ---
#  managedmac::energysaver::desktop:
#     ACPower:
#       'Automatic Restart On Power Loss': true
#       'Disk Sleep Timer-boolean': true
#       'Display Sleep Timer': 15
#       'Sleep On Power Button': false
#       'Wake On LAN': true
#       'System Sleep Timer': 30
#     Schedule:
#       RepeatingPowerOff:
#         eventtype: sleep
#         time: 1410
#         weekdays: 127
#       RepeatingPowerOn:
#         eventtype: wakepoweron
#         time: 480
#         weekdays: 127
#  managedmac::energysaver::portable:
#     ACPower:
#       'Automatic Restart On Power Loss': true
#       'Disk Sleep Timer-boolean': true
#       'Display Sleep Timer': 15
#       'Wake On LAN': true
#       'System Sleep Timer': 30
#     BatteryPower:
#       'Automatic Restart On Power Loss': false
#       'Disk Sleep Timer-boolean': true
#       'Display Sleep Timer': 5
#       'System Sleep Timer': 10
#       'Wake On LAN': true
#
# @example my_manifest.pp
#   include managedmac::activedirectory
#
# @example Create an Desktop settings Hash
#     $desktop = {
#      "ACPower" => {
#        "Automatic Restart On Power Loss" => true,
#        "Disk Sleep Timer-boolean"        => true,
#        "Display Sleep Timer"             => 15,
#        "Sleep On Power Button"           => false,
#        "Wake On LAN"                     => true,
#        "System Sleep Timer"              => 30,
#       },
#       "Schedule" => {
#         "RepeatingPowerOff" => {
#           "eventtype" => "sleep",
#           "time"      => 1410,
#           "weekdays"  => 127
#         },
#         "RepeatingPowerOn" => {
#           "eventtype" => "wakepoweron",
#           "time"      => 480,
#           "weekdays"  => 127
#         }
#       }
#     }
#    
# @example Create an Portable settings Hash
#     $portable = {
#       "ACPower" => {
#         "Automatic Restart On Power Loss" => true,
#         "Disk Sleep Timer-boolean"        => true,
#         "Display Sleep Timer"             => 15,
#         "Wake On LAN"                     => true,
#         "System Sleep Timer"              => 30,
#       },
#       "BatteryPower" => {
#         "Automatic Restart On Power Loss" => false,
#         "Disk Sleep Timer-boolean"        => true,
#         "Display Sleep Timer"             => 5,
#         "System Sleep Timer"              => 10,
#         "Wake On LAN"                     => true
#       }
#     }
#    
# @example Invoke the class with params
#     class { 'managedmac::energysaver':
#       desktop => $desktop,
#       laptop  => $portable,
#     }
#
class managedmac::energysaver (
  Hash $desktop  = {},
  Hash $portable = {},

) {
  $params = {
    'com.apple.MCX' => {
      'com.apple.EnergySaver.desktop.ACPower'       => $desktop['ACPower'],
      'com.apple.EnergySaver.desktop.Schedule'      => $desktop['Schedule'],
      'com.apple.EnergySaver.portable.ACPower'      => $portable['ACPower'],
      'com.apple.EnergySaver.portable.BatteryPower' =>
        $portable['BatteryPower'],
      'com.apple.EnergySaver.portable.Schedule'     => $portable['Schedule'],
      'com.apple.EnergySaver.desktop.ACPower-ProfileNumber'       => -1,
      'com.apple.EnergySaver.portable.ACPower-ProfileNumber'      => -1,
      'com.apple.EnergySaver.portable.BatteryPower-ProfileNumber' => -1,
    }
  }

  $content = process_mobileconfig_params($params)

  $mobileconfig_ensure = empty($desktop) and empty($portable)

  $ensure = $mobileconfig_ensure ? {
    true  => absent,
    false => present,
  }

  $organization = hiera('managedmac::organization', 'SFU')

  mobileconfig { 'managedmac.energysaver.alacarte':
    ensure       => $ensure,
    displayname  => 'Managed Mac: Energy Saver',
    description  => 'Energy Saver configuration. Installed by Puppet.',
    organization => $organization,
    content      => $content,
  }

}
