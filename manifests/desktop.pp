# @summary
#   Leverages the Mobileconfig type to deploy a Desktop Picture profile.
#
# @note
#   All of the parameter defaults are 'undef' so including/containing the class
#   is not sufficient for confguration. You must activate the params by giving
#   them a value.
#
# @note
#   Currently there is a bug with this profile setting that does
#   not allow users to change the desktop picture regardless of the
#   'locked' setting.
#
# @param override_picture_path
#   Set the path of the default desktop picture on OS X.
#
# @param locked
#   This locks the value of the desktop picture so that users can
#   select their own picture or not (read Note above).
# @example defaults.yaml
#  ---
#  managedmac::desktop::override_picture_path:
#    "/Library/Desktop Pictures/Abstract.jpg"
#  managedmac::desktop::locked: true
#
# @example my_manifest.pp
#  include managedmac::desktop
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
# @example simplte configuration
#  class { 'managedmac::desktop':
#    override_picture_path  => '/Library/Desktop Pictures/Abstract.jpg',
#    locked                 => true,
#  }
#
class managedmac::desktop (
  Optional[Stdlib::Absolutepath] $override_picture_path = undef,
  Optional[Boolean] $locked                             = undef,
) {

  $params = {
    'com.apple.desktop' => {
      'override-picture-path' => $override_picture_path,
      'locked'                => $locked,
    },
  }

  # Should return Array
  $content = process_mobileconfig_params($params)

  $mobileconfig_ensure = empty($content) ? {
    true  => 'absent',
    false => 'present',
  }

  $organization = hiera('managedmac::organization', 'SFU')

  mobileconfig { 'managedmac.desktop.alacarte':
    ensure       => $mobileconfig_ensure,
    content      => $content,
    displayname  => 'Managed Mac: Desktop Picture',
    description  => 'Desktop Picture configuration. Installed by Puppet.',
    organization => $organization,
  }

}
