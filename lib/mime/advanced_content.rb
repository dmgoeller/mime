module Mime

  # Represents a message content with additional options.
  #
  # ### Example
  #
  # The following example illustrates how to create a file attachment using
  # the `AdvancedContent` class:
  #
  # ```ruby
  # attachment = PlainContent.binary("Lorem ipsum dolor sit amet, ...")
  # AdvancedContent.new(attachment, filename: "foo.bar")
  # ```
  #
  # Produces:
  #
  # ```
  # Content-Disposition: attachment; filename="foo.bar"; size=31
  # Content-Type: application/octet-stream
  # Content-Transfer-Encoding: base64
  #
  # TG9yZW0gaXBzdW0gZG9sb3Igc2l0IGFtZXQsIC4uLg==
  # ```
  #
  # ### References
  #
  # See [RFC 2183](https://tools.ietf.org/html/rfc2183) for details about
  # the `Content-Disposition` header field.
  #
  class AdvancedContent < MessageContent

    # Creates a message content with the specified options.
    #
    # ###Options:
    #
    # * `:disposition_type` - Specifies the content's disposition type
    #   (default: `"attachment"`).
    # * `:filename`: Specifies the filename.
    # * `:creation_date` - Specifies the date-time at which the file was
    #   created.
    # * `:modification_date` - Specifies the date-time at which the file
    #   was last modified.
    # * `:read_date` - Specifies the date-time at which the file was last
    #   read.
    # * `:content_id` - Specifies the content ID.
    #
    def initialize(content, options = {})
      @content           = content
      @disposition_type  = options[:disposition_type] ||= "attachment"
      @filename          = options[:filename]
      @creation_date     = options[:creation_date]
      @modification_date = options[:modification_date]
      @read_date         = options[:read_date]
      @content_id        = options[:content_id]
    end

    # The content.
    #
    attr_accessor :content

    # The optional content ID.
    #
    attr_accessor :content_id

    # The disposition type (`"attachment"` or `"inline"`).
    #
    attr_accessor :disposition_type

    # The optional filename.
    #
    attr_accessor :filename

    # The optional date-time at which the file was created.
    #
    attr_accessor :creation_date

    # The optional date-time at which the file was last modified.
    #
    attr_accessor :modification_date

    # The optional date-time at which the file was last read.
    #
    attr_accessor :read_date

    # See `MessageContent#write`.
    #
    def write(io)
      io = Writer.get(io)

      # `Content-ID` header field
      io.write_header_field("Content-ID", @content_id)

      # `Content-Disposition` header field
      param = {}

      param["filename"]          = @filename if @filename
      param["creation-date"]     = @creation_date if @creation_date
      param["modification-date"] = @modification_date if @modification_date
      param["read-date"]         = @read_date if @read_date
      param["size"]              = @content.size if @content.respond_to? :size

      io.write_header_field("Content-Disposition", @disposition_type, param)

      # content
      io.write_content(content)
    end
  end
end
