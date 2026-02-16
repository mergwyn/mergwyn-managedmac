# @summary
#   Dynamically create Puppet File resources using the Puppet built-in
#   'create_resources' function.
#
# @param objects
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
#     managedmac::files::objects:
#       /Users/Shared/example_file_a.txt:
#         ensure: file
#         owner: root
#         group: admin
#         mode: '0644'
#         content: "This is an example of how to create a file using the \
#     content parameter."
#       /Users/Shared/example_file_b.txt:
#         ensure: file
#         owner: root
#         group: admin
#         mode: '0644'
#         source: puppet:///modules/my_module/example_file_b.txt
#       /Users/Shared/example_directory:
#         ensure: directory
#         owner: root
#         group: admin
#         mode: '0755'
#    
# @example my_manifest.pp
#      include managedmac::files
#    
# @example Create some Hashes
#      $defaults = { 'owner' => 'root', 'group' => 80, }
#      $objects = {
#         '/Users/Shared/test_file_a.txt' => { 'content' => 'Example A.' },
#         '/Users/Shared/test_file_b.txt' => { 'content' => 'Example B.' },
#      }
#    
#      class { 'managedmac::files':
#        objects  => $objects,
#        defaults => $defaults,
#      }
#
class managedmac::files (
  Hash[String,Hash] $objects = {},
  Hash $defaults             = {},
) {

  unless empty ($objects) {
    create_resources(file, $objects, $defaults)
  }

}
