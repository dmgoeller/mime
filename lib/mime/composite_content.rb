module Mime

  # Represents a message content consisting of multiple parts.
  #
  # ### Example
  #
  # The following example illustrates how to create a `multipart` message
  # content using the `CompositeContent` class:
  #
  # ```ruby
  # content = CompositeContent.new("mixed", "boundary")
  # content << PlainContent.textual("Lorem ipsum dolor sit amet, ...")
  #
  # attachment = PlainContent.binary("Lorem ipsum dolor sit amet, ...")
  # content << AdvancedContent.new(attachment, filename: "foo.bar")
  # ```
  #
  # Produces:
  #
  # ```
  # Content-Type: multipart/mixed; boundary="=_boundary"
  #
  # --=_boundary
  # Content-Type: text/plain; charset=utf-8
  # Content-Transfer-Encoding: quoted-printable
  #
  # Lorem ipsum dolor sit amet, ...
  # --=_boundary
  # Content-Disposition: attachment; filename=foo.bar; size=31
  # Content-Type: application/octet-stream
  # Content-Transfer-Encoding: base64
  #
  # TG9yZW0gaXBzdW0gZG9sb3Igc2l0IGFtZXQsIC4uLg==
  # --=_boundary--
  # ```
  #
  # ### References
  #
  # See [RFC 2046, section 5.1,](https://tools.ietf.org/html/rfc2046#section-5.1)
  # for further information about multiparts.
  #
  class CompositeContent < MessageContent

    # Creates a composite content with the specified type, pre-defined boundary
    # and parts.
    #
    def initialize(type = "mixed", boundary = nil, *parts)
      @type     = type
      @boundary = boundary
      @parts    = parts
    end

    # The type of the composite content, typically `"mixed"` or `"alternative"`.
    #
    attr_accessor :type

    # The pre-defined boundary of the composite content.
    #
    attr_accessor :boundary
    
    # The parts of the composite content.
    #
    attr_accessor :parts

    # Returns the part at the given position, same as `parts.[](index)`.
    #
    def [](index)
      parts[index]
    end

    # Sets the part at the given position, same as `parts.[]=(index, part)`.
    #
    def []=(index, part)
      parts[index] = part
    end

    # Appends `content` to the composite content, same as `parts.<<(content)`.
    #
    def <<(content)
      @parts << content
    end

    # See `MessageContent#write`.
    #
    def write(io)
      io = Writer.get(io)

      boundary = "=_#{@boundary ||= object_id.to_s(16)}"

      # `Content-Type` header field
      io.write_header_field(
        "Content-Type",
        "multipart/#{@type}",
        "boundary" => "\"#{boundary}"
      )

      # blank line
      io.write_line

      # parts
      @parts.each do |part|
        io.write_line("--#{boundary}")
        io.write_content(part)
      end
      io.write_line("--#{boundary}--")
    end
  end
end
