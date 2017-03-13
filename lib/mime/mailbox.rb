module Mime

  # Represents a mailbox consisting of an email address and an optional display
  # name. This class could be used to specifiy the value of an originator or a
  # destination header field of a message, e.g. `From` or `To`. 
  #
  # ### References
  #
  # See [RFC 5322, section 3.4,](https://tools.ietf.org/html/rfc5322#section-3.4)
  # for details about mailboxes.
  #
  class Mailbox

    include Encoder

    # Creates a mailbox with the given email address and display name.
    #
    def initialize(email_address, display_name = nil)
      @email_address = email_address
      @display_name  = display_name
    end

    # The email address (= _addr-spec_) of the mailbox.
    #
    attr_accessor :email_address

    # The optional display name of the mailbox.
    #
    attr_accessor :display_name

    # Returns the MIME representation of the mailbox as a string.
    #
    # Examples:
    #
    # ```ruby
    # # email address only:
    # mailbox = Mailbox.new("a.smith@foo.bar")
    # mailbox.to_s(false) #=> a.smith@foo.bar
    # mailbox.to_s(true)  #=> a.smith@foo.bar
    #
    # # email address and display name:
    # mailbox = Mailbox.new("a.smith@foo.bar", "Allison Smith")
    # mailbox.to_s(false) #=> "Allison Smith <a.smith@foo.bar>"
    # mailbox.to_s(true)  #=> "Allison Smith <a.smith@foo.bar>"
    #
    # # display name with non-ascii characters:
    # mailbox = Mailbox.new("t.mueller@bar.de", "Thomas Müller")
    # mailbox.to_s(false) #=> "Thomas Müller <t.mueller@foo.bar>"
    # mailbox.to_s(true)  #=> "=?utf-8?Q?Thomas=20M=C3=BCller?= <t.mueller@foo.bar>"
    # ```
    #
    def to_s(encoded = false)
      display_name = @display_name.to_s
      addr_spec    = @email_address.to_s

      if display_name.empty?
        # => addr-spec without '<' and '>'
        String.new(addr_spec)
      else
        # => display-name '<' addr-spec '>'
        if encoded && !display_name.ascii_only?
          mailbox = encoded_word(display_name)
        else
          mailbox = String.new(display_name)
        end

        mailbox << " "
        mailbox << "<" unless addr_spec.start_with?("<")
        mailbox << addr_spec
        mailbox << ">" unless addr_spec.end_with?(">")
      end
    end
  end
end
