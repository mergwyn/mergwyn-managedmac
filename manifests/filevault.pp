# @summary
#   Leverages the Mobileconfig type to deploy a FileVault 2 profile. It provides
#   only a subset of the options available to the profile and does not conform to
#   the Apple defaults. Read the documentation.
#
# @param enable
#   Whether to enable FileVault or not.
#
# @param use_recovery_key
#   Set to true to create a personal recovery key.
#
# @param show_recovery_key
#   Set to true to display the personal recovery key to the user after
#   FileVault is enabled.
#
# @param output_path
#   Path to the location where the recovery key and computer information
#   plist will be stored.
#
# @param use_keychain
#   If set to true and no certificate information is provided in this
#   payload, the keychain already created at
#   /Library/Keychains/FileVaultMaster.keychain will be used when the
#   institutional recovery key is added.
#
# @param keychain_file
#   An absolute path or puppet:/// style URI from whence to gather an FVMI.
#   It will install and manage /Library/Keychains/FileVaultMaster.keychain.
#   Only works when $use_keychain is true.
#
# @param destroy_fv_key_on_standby
#   Prevent saving the key across standby modes.
#
# @param dont_allow_fde_disable
#   Prevent users from disabling FDE.
#
# @param remove_fde
#   Removes FDE if $enable is false and the disk is encrypted.
#
# @example defaults.yaml
#     ---
#     managedmac::filevault::enable: true
#     managedmac::filevault::use_recovery_key: true
#     managedmac::filevault::show_recovery_key: true
#
# @example my_manifest.pp
#      include managedmac::filevault
#
# @example Simple test
#      class { 'managedmac::filevault':
#        enable => true,
#      }
#
class managedmac::filevault (

  Optional[Boolean] $enable                     = undef,
  Optional[Boolean] $use_recovery_key           = undef,
  Optional[Boolean] $show_recovery_key          = undef,
  Optional[Stdlib::Absolutepath] $output_path   = undef,
  Optional[Boolean] $use_keychain               = undef,
  Optional[Stdlib::Filesource] $keychain_file   = undef,
  Optional[Boolean] $destroy_fv_key_on_standby  = undef,
  Optional[Boolean] $dont_allow_fde_disable     = undef,
  Optional[Boolean] $remove_fde                 = undef,

){

  unless $enable == undef {
    if $use_keychain == true {
      file { 'filevault_master_keychain':
        ensure => file,
        owner  => root,
        group  => wheel,
        mode   => '0644',
        path   => '/Library/Keychains/FileVaultMaster.keychain',
        source => $keychain_file;
      }
    }

    $params = {
      'com.apple.MCX.FileVault2' => {
        'Enable'          => 'On',
        'Defer'           => true,
        'UseRecoveryKey'  => $use_recovery_key,
        'ShowRecoveryKey' => $show_recovery_key,
        'OutputPath'      => $output_path,
        'UseKeychain'     => $use_keychain,
      },
      'com.apple.MCX' => {
        'DestroyFVKeyOnStandby' => $destroy_fv_key_on_standby,
        'dontAllowFDEDisable'   => $dont_allow_fde_disable,
      },
    }

    $content = process_mobileconfig_params($params)

    $organization = hiera('managedmac::organization','SFU')

    $ensure = $enable ? {
      true     => present,
      default  => absent,
    }

    mobileconfig { 'managedmac.filevault.alacarte':
      ensure       => $ensure,
      content      => $content,
      displayname  => 'Managed Mac: FileVault 2',
      description  => 'FileVault 2 configuration. Installed by Puppet.',
      organization => $organization,
    }

    if ($enable == false) and ($::filevault_active == true) and ($remove_fde == true)  {
      exec { 'decrypt_the_disk':
        command => '/usr/bin/fdesetup disable',
        returns => [0,1],
      }
    }

  }
}
