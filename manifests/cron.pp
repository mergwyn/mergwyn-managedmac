# @summary
#   Dynamically create Puppet Cron resources using the Puppet built-in
#   'create_resources' function.
#
# @note
#   We do some validation of data, but the usual caveats apply: garbage in,
#   garbage out.
#
# @param jobs
#   This is a Hash of Hashes.
#   The hash should be in the form { title => { parameters } }.
#   See http://tinyurl.com/7783b9l, and the examples below for details.
#
# @param defaults
#   A Hash that defines the default values for the resources created.
#   See http://tinyurl.com/7783b9l, and the examples below for details.
#
# @example defaults.yaml
#     managedmac::cron::jobs:
#       logrotate:
#         command: '/usr/sbin/logrotate'
#         user:    'root'
#         hour:    2
#         minute:  0
#
# @example my_manifest.pp
#     include managedmac::cron
#
# @example Create some Hashes
#     $defaults = { user => 'root', hour => 2, minute => 0 }
#     $jobs = {
#        'logrotate' => { 'command' => '/usr/bin/who > /tmp/who.dump' },
#     }
#   
#     class { 'managedmac::cron':
#       jobs     => $jobs,
#       defaults => $defaults,
#     }
#
class managedmac::cron (
  Hash[String,Hash] $jobs = {},
  Hash $defaults          = {},
) {

  unless empty ($jobs) {
    create_resources(cron, $jobs, $defaults)
  }

}
