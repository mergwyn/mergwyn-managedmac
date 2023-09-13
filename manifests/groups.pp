# @summary
#   Dynamically create Puppet Macgroup resources using the Puppet built-in
#   'create_resources' function.
#
# @param accounts
#   This is a Hash of Hashes.
#   The hash should be in the form { title => { parameters } }.
#   See http://tinyurl.com/7783b9l, and the examples below for details.
#
# @param defaults
#   A Hash that defines the default values for the resources created.
#   See http://tinyurl.com/7783b9l, and the examples below for details.
#
# @example defaults.yaml
#     ---
#     managedmac::groups::defaults:
#       ensure: present
#     managedmac::groups::accounts:
#       foo_group:
#         gid: 998
#         users:
#           - foo
#           - bar
#       bar_group:
#         gid: 999
#         nestedgroups:
#           - foo_group
#
# @example my_manifest.pp
#     include managedmac::groups
#
#
# @example Create some hashes
#     $defaults = { 'ensure' => 'present', }
#     $accounts = {
#       'foo_group' => { 'gid' => 511, 'users'        => ['foo'] },
#       'bar_group' => { 'gid' => 522, 'nestedgroups' => ['foo_group'] },
#     }
#
#     class { 'managedmac::groups':
#       accounts => $accounts,
#       defaults => $defaults,
#     }
#
class managedmac::groups (
  Optional[Hash[String,Hash]] $accounts = undef,
  Hash $defaults                        = {}
) {

#  if is_hash(hiera('managedmac::activedirectory::enable', false)) {
#    require managedmac::activedirectory
#  }

  unless $accounts == undef {
    if empty ($accounts) {
      fail('Parameter Error: $accounts is empty')
    } else {
      create_resources(macgroup, $accounts, $defaults)
    }
  }
}
