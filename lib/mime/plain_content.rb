module Mime

  # Represents a textual or binary message content.
  #
  # ### Example
  #
  # The following example illustrates how to create a plain text body using
  # the `PlainContent` class:
  #
  # ```ruby
  # MessageContent.new("Lorem ipsum ...", "text/plain", "quoted-printable")
  # ```
  #
  # Produces:
  #
  # ```
  # Content-Type: text/plain; charset=utf-8
  # Content-Transfer-Encoding: quoted-printable
  #
  # Lorem ipsum ...
  # ```
  #
  # ### References
  #
  # See [RFC 2045](https://tools.ietf.org/html/rfc2045) for details about
  # formatting message bodies.
  #
  class PlainContent < MessageContent

    # Creates a textual message content with the specified text and content
    # type. The default transfer encoding is `"quoted-printable"`.
    #
    def self.textual(text, content_type = "text/plain")
      PlainContent.new(text, content_type, "quoted-printable")
    end

    # Creates a binary message content with the specified data and content
    # type. The default tranfer encoding is `"base64"`.
    #
    def self.binary(bin, content_type = "application/octet-stream")
      PlainContent.new(bin, content_type, "base64")
    end

    # Creates a textual or binary message content with the specified content,
    # content type, and transfer encoding.
    #
    def initialize(content, content_type, transfer_encoding)
      @content           = content
      @content_type      = content_type
      @transfer_encoding = transfer_encoding
      @encoded_content   = nil
    end

    # :attr_accessor: content
    # The textual or binary content.

    attr_reader :content #:nodoc:

    def content=(content) #:nodoc:
      @content         = content
      @encoded_content = nil
    end

    # The content type, for example `"text/plain"`, `"text/html`,
    # `"image/jpeg"`, or `"application/pdf"`.
    #
    attr_accessor :content_type

    # :attr_accessor: transfer_encoding
    # The transfer encoding, for example `"7bit"`, `"base64"`, or
    # `"quoted-printable"`.

    attr_reader :transfer_encoding #:nodoc:

    def transfer_encoding=(transfer_encoding) #:nodoc:
      @transfer_encoding = transfer_encoding
      @encoded_content   = nil
    end

    # Returns the approximated size in bytes.
    #
    def size
      content.respond_to?(:bytesize) ? content.bytesize : nil
    end

    # See `MessageContent#write`.
    #
    def write(io)
      io = Writer.get(io)

      # `Content-Type` header field
      param = {}

      if @content_type.to_s.start_with?("text/")
        param["charset"] = @content.encoding.to_s.downcase
      end
      io.write_header_field("Content-Type", @content_type, param)

      # `Content-Transfer-Encoding` header field
      io.write_header_field("Content-Transfer-Encoding", @transfer_encoding)

      # blank line
      io.write_line

      # body
      if @content && @encoded_content.nil?
        # encode the content now
        case transfer_encoding.to_s.downcase
        when "identity", "7bit", "8bit"
          @encoded_content = [content]
        when "quoted-printable"
          @encoded_content = quoted_printable(content)
        when "base64"
          @encoded_content = base64(content)
        else
          raise "unsupported content transfer encoding: #{@transfer_encoding}."
        end
      end

      @encoded_content.each { |line| io.write_line(line) } if @encoded_content
    end
  end
end
