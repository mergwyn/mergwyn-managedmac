# -*- coding: utf-8 -*-

require 'libxml'

module CFPropertyList # rubocop:disable Style/ClassAndModuleChildren
  # XML parser
  class LibXMLParser < XMLParserInterface
    # read a XML file
    # opts::
    # * :file - The filename of the file to load
    # * :data - The data to parse
    def load(opts)
      doc = nil

      doc = if opts.key?(:file)
              LibXML::XML::Document.file(opts[:file], options: LibXML::XML::Parser::Options::NOBLANKS | LibXML::XML::Parser::Options::NOENT)
            else
              LibXML::XML::Document.string(opts[:data], options: LibXML::XML::Parser::Options::NOBLANKS | LibXML::XML::Parser::Options::NOENT)
            end

      if doc
        root = doc.root.first
        return import_xml(root)
      end
    rescue LibXML::XML::Error => e
      raise CFFormatError, 'invalid XML: ' + e.message
    end

    # serialize CFPropertyList object to XML
    # opts = {}:: Specify options: :formatted - Use indention and line breaks
    def to_str(opts = {})
      doc = LibXML::XML::Document.new

      doc.root = LibXML::XML::Node.new('plist')
      doc.encoding = LibXML::XML::Encoding::UTF_8

      doc.root['version'] = '1.0'
      doc.root << opts[:root].to_xml(self)

      # ugly hack, but there's no other possibility I know
      str = doc.to_s(indent: opts[:formatted])
      str1 = ''
      first = false
      str.each_line do |line|
        str1 << line
        unless first
          str1 << "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n" if line =~ %r{^\s*<\?xml}
        end

        first = true
      end

      str1.force_encoding('UTF-8') if str1.respond_to?(:force_encoding)
      str1
    end

    def new_node(name)
      LibXML::XML::Node.new(name)
    end

    def new_text(val)
      LibXML::XML::Node.new_text(val)
    end

    def append_node(parent, child)
      parent << child
    end

    protected

    # get the value of a DOM node
    def get_value(n)
      content = if n.children?
                  n.first.content
                else
                  n.content
                end

      content.force_encoding('UTF-8') if content.respond_to?(:force_encoding)
      content
    end

    # import the XML values
    def import_xml(node)
      ret = nil

      case node.name
      when 'dict'
        hsh = {}
        key = nil

        if node.children?
          node.children.each do |n|
            next if n.text? # avoid a bug of libxml
            next if n.comment?

            # rubocop:disable Metrics/BlockNesting
            if n.name == 'key'
              key = get_value(n)
            else
              raise CFFormatError, 'Format error!' if key.nil?
              hsh[key] = import_xml(n)
              key = nil
            end
            # end rubocop:disable
          end
        end

        ret = CFDictionary.new(hsh)

      when 'array'
        ary = []

        if node.children?
          node.children.each do |n|
            next if n.text? # avoid a bug of libxml
            next if n.comment?
            ary.push import_xml(n)
          end
        end

        ret = CFArray.new(ary)

      when 'true'
        ret = CFBoolean.new(true)
      when 'false'
        ret = CFBoolean.new(false)
      when 'real'
        ret = CFReal.new(get_value(node).to_f)
      when 'integer'
        ret = CFInteger.new(get_value(node).to_i)
      when 'string'
        ret = CFString.new(get_value(node))
      when 'data'
        ret = CFData.new(get_value(node))
      when 'date'
        ret = CFDate.new(CFDate.parse_date(get_value(node)))
      end

      ret
    end
  end
end

# eof
