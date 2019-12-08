module Mime

  # Represents a message.
  #
  # ### Example
  #
  # The following example illustrates how to create a plain text message using
  # the `Message` class:
  #
  # ```ruby
  # message = Message.new(PlainContent.textual("Lorem ipsum dolor sit amet, ..."))
  # message["From"]    = Mailbox.new("a.smith@foo.bar", "Allison Smith")
  # message["To"]      = Mailbox.new("t.mueller@bar.foo", "Thomas Müller")
  # message["Subject"] = "Welcome Thomas"
  # ```
  #
  # Produces:
  #
  # ```
  # MIME-Version: 1.0
  # From: Allison Smith <a.smith@foo.bar>
  # To: =?utf-8?Q?Thomas=20M=C3=BCller?= <t.mueller@bar.foo>
  # Subject: Welcome Thomas
  # Content-Type: text/plain; charset=utf-8
  # Content-Transfer-Encoding: quoted-printable
  #
  # Lorem ipsum dolor sit amet, ...
  # ```
  #
  # #### References
  #
  # See [RFC 5322](https://tools.ietf.org/html/rfc5322) for details about the
  # format of MIME messages.
  #
  class Message < MessageContent

    # Creates a message with the given content and header fields.
    #
    def initialize(content = nil, header = {})
      @header  = header
      @content = content
    end

    # The header fields.
    #
    attr_accessor :header

    # The message content.
    #
    attr_accessor :content

    # Returns the body of the given header field, same as `header.[](name)`.
    #
    def[](name)
      header[name]
    end

    # Sets the body of the given header field, same as `header.[]=(name, body)`.
    #
    def[]=(name, body)
      header[name] = body
    end

    # Appends the given content to the message.
    #
    def <<(content)
      if @content.nil?
        @content = content
      elsif @content.is_a?(CompositeContent)
        @content << content
      else
        @content = CompositeContent.new("mixed", nil, @content)
      end
    end

    # See `MessageContent#write`.
    #
    def write(io)
      io = Writer.get(io)

      # header fields
      io.write_header_field("MIME-Version", "1.0")

      @header.each do |name, value|
        io.write_header_field(name, value)
      end

      # content
      io.write_content(content)
    end
  end
end
