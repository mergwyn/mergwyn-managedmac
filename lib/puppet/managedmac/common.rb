require 'cfpropertylist'
require 'digest/md5'

# common functions
module ManagedMacCommon
  RECORD_TYPES             = [:users, :groups, :computers, :computergroups].freeze
  DSCL                     = '/usr/bin/dscl'.freeze
  SEARCH_NODE              = '/Search'.freeze
  FILTERED_PAYLOAD_KEYS    = ['PayloadIdentifier',
                              'PayloadDescription',
                              'PayloadDisplayName',
                              'PayloadOrganization',
                              # TODO: confirm deletion
                              # 'PayloadRemovalDisallowed',
                              'PayloadScope',
                              'PayloadVersion'].freeze

  DO_NOT_DESTRING = ['LastSeenCloudProductVersion'].freeze

  # Generate a UUID using the supplied content
  def self.content_to_uuid(content)
    digest  = Digest::MD5.hexdigest content.to_s
    pattern = %r{\A([0-9a-f]{8})([0-9a-f]{4})([0-9a-f]{4})([0-9a-f]{4})([0-9a-f]{12})\z}
    digest.gsub pattern, '\\1-\\2-\\3-\\4-\\5'
  end

  # Recurse the data argument and transform it into real Ruby objects
  def self.destringify(data)
    case data
    when %r{\A-?\d+\z} # Fixnum
      data.to_i
    when %r{\A-?\d+\.\d+\z} # Float
      data.to_f
    when %r{\Atrue\z} # TrueClass
      true
    when %r{\Afalse\z} # FalseClass
      false
    when NilClass
      data.to_s
    when String, Integer, Float, TrueClass, FalseClass, Time, Date, DateTime
      # Leave my elevator alone
      data
    when Array
      data.map { |e| destringify e }
    when Hash
      array = data.map do |k, v|
        DO_NOT_DESTRING.include?(k.to_s) ? [k, v] : [k, destringify(v)]
      end
      Hash[array]
    else
      raise Puppet::Error, "Cast Error: #destringify unknown type:
        #{data.class}, #{data}"
    end
  end

  # Search OpenDirectory
  # - find records in OpenDirectory given type, attribute and value
  # - returns Array of record names (not the actual records)
  def self.dscl_find_by(record_type, attribute, value)
    unless RECORD_TYPES.member? record_type.to_sym
      raise Puppet::Error, "not an OpenDirectory type: #{record_type}"
    end

    if attribute.empty? || value.empty?
      raise Puppet::Error, "Search params empty: \'#{attribute}\', \'#{value}\'"
    end

    # If we are looking for a record name, if might have backslahes in it
    # Active Directory records are returned this way, so split it.
    domain, value = value.split('\\') if value =~ %r{\w\\\w+} && attribute.eql?('name')

    cmd_args = [DSCL, SEARCH_NODE, '-search',
                "/#{record_type.to_s.capitalize}", attribute.to_s, "\'#{value}\'"]

    # Excute the search
    dscl_result = `#{cmd_args.join(' ')}`

    # If there is a domain component to the record name, rejoin them
    if domain && attribute.eql?('name')
      value = [domain, value].join('\\') if domain
    end

    dscl_result.scan %r{#{Regexp.quote(value)}}i
  end

  def nil_or_empty?(value)
    value.nil? || value.empty?
  end
end
