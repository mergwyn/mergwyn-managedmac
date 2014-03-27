# require 'pry'
require 'cfpropertylist'
require 'securerandom'
require 'fileutils'

Puppet::Type.type(:mobileconfig).provide(:mobileconfig) do
  
  commands :profiles => '/usr/bin/profiles'
  
  mk_resource_methods
  
  class << self
    
    # Returns an array of a provider instance for every resource discovered
    def instances
      all = get_installed_profiles
      all.collect { |profile| new(get_resource_properties(profile)) }
    end
    
    # Puppet MAGIC
    def prefetch(resources)
      instances.each do |prov|
        if resource = resources[prov.name]
          resource.provider = prov
        end
      end
    end
    
    # Use the profiles command to return an array containing a Hash
    # representation of each of the profiles installed
    # Returns: Array
    def get_installed_profiles
      dir  = Dir.mktmpdir
      path = [dir, "profiles#{SecureRandom.hex}.plist"].join("/")
      
      begin
        profiles(['-P', '-o', path])
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "#mobileconfig: command returned non-zero `profiles -P -o #{path}`"
      end
      
      parsed = parse_propertylist path
      FileUtils.rm_rf path
      return [] if parsed.empty?
      parsed['_computerlevel']
    end
    
    # Profile read from profile dump goes in, Puppet resource comes out
    def get_resource_properties(profile)
      return {} if profile.nil?
      content = profile['ProfileItems'].collect do |item|
        { 'PayloadType' => item['PayloadType'] }.merge item['PayloadContent']
      end
      # Ladies and gentleman, the resource
      {
        :name              => profile['ProfileIdentifier'],
        :description       => profile['ProfileDescription'],
        :displayname       => profile['ProfileDisplayName'],
        :organization      => profile['ProfileOrganization'],
        :removaldisallowed => profile['ProfileUninstallPolicy'] == 'allowed' ? 'false' : 'true', # Ridiculous
        :provider          => :mobileconfig,
        :ensure            => :present,
        :content           => content,
      }
    end
    
    # Parse a plist and return a Ruby object
    def parse_propertylist(file)
      plist = CFPropertyList::List.new(:file => file)
      raise Puppet::Error, "Cannot parse: #{file}" if plist.nil?
      CFPropertyList.native_types(plist.value)
    end
    
  end
  
  def initialize(value={})
    super(value)
    @property_flush = {}
  end
  
  def create
    @property_flush[:ensure] = :present
  end
  
  def destroy
    @property_flush[:ensure] = :absent
  end
  
  def exists?
    @property_hash[:ensure] == :present
  end
  
  # Provider Helper method
  # Build and install the mobileconfig OR destroy it
  def coalesce_mobileconfig
    path = [Dir.mktmpdir, "#{SecureRandom.hex}.mobileconfig"].join("/")
    
    # Transform @property_hash
    transform = {
      'PayloadIdentifier'        => @resource[:name],
      'PayloadDescription'       => @resource[:description],
      'PayloadDisplayName'       => @resource[:displayname],
      'PayloadOrganization'      => @resource[:organization],
      'PayloadRemovalDisallowed' => @resource[:removaldisallowed] == false ? false : true,
      'PayloadScope'             => 'System',
      'PayloadType'              => 'Configuration',
      'PayloadUUID'              => SecureRandom.uuid,
      'PayloadVersion'           => 1,
      'PayloadContent'           => @resource[:content] || []
    }
    
    if @property_flush[:ensure] == :absent
      
      # Remove the profile
      id = @resource[:name]
      begin
        profiles(['-R', '-p', id])
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "#mobileconfig: command returned non-zero `profiles -R -p #{id}`"
      end
      
    else
      
      # Build and install the profile
      transform['PayloadContent'].collect! do |payload|
        embedded_payload_uuid = SecureRandom.uuid
        payload.merge!({
          'PayloadIdentifier' => [transform['PayloadIdentifier'],
                                  embedded_payload_uuid].join('.'),
          'PayloadEnabled'    => true,
          'PayloadUUID'       => embedded_payload_uuid,
          'PayloadVersion'    => 1,
        })
        payload
      end
      
      plist = CFPropertyList::List.new
      plist.value = CFPropertyList.guess(transform)
      plist.save(path, CFPropertyList::List::FORMAT_XML)
      
      begin
        profiles(['-I', '-F', path])
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "#mobileconfig: command returned non-zero `profiles -I -F #{path}`"
      end
      
      FileUtils.rm_rf path
    end
  end
  
  # Puppet MAGIC
  # The flush method is called once per resource whenever the 
  # ‘is’ and ‘should’ values for a property differ (and synchronization needs to occur).
  # As per Shit Gary Says: http://garylarizza.com/blog/2013/12/15/seriously-what-is-this-provider-doing/
  def flush
    coalesce_mobileconfig
    
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    all_profiles = self.class.get_installed_profiles
    this_profile = all_profiles.find { |profile| profile['ProfileIdentifier'].eql? resource[:name] }
    
    @property_hash = self.class.get_resource_properties(this_profile)
  end
  
end