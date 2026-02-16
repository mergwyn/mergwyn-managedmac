# @summary
#   Dynamically create Puppet Exec resources using the Puppet built-in
#   'create_resources' function.
#
# @param commands
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
#     managedmac::execs::commands:
#       who_dump:
#         command: '/usr/bin/who > /tmp/who.dump'
#       ps_dump:
#         command: '/bin/ps aux > /tmp/ps.dump'
#    
# @example my_manifest.pp
#      include managedmac::execs
#    
# @example Create some Hashes
#      $defaults = { 'returns' => [0,1], }
#      $commands = {
#        'who_dump' => { 'command' => '/usr/bin/who > /tmp/who.dump' },
#        'ps_dump'  => { 'command' => '/bin/ps aux  > /tmp/ps.dump' },
#      }
#    
#      class { 'managedmac::execs':
#        commands  => $commands,
#        defaults => $defaults,
#      }
#
class managedmac::execs (
  Hash[String,Hash] $commands = {},
  Hash              $defaults = {},
) {

  unless empty ($commands) {
    create_resources(exec, $commands, $defaults)
  }

}
