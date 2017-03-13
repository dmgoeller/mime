module Mime

  # Provides methods for encoding strings and binary data in _base64_ or
  # _quoted-printable_.
  #
  module Encoder

    # Returns the _base64_ representation of `bin` as an array of strings.
    #
    def base64(bin)
      return [] if bin.nil?
      
      base64 = [bin].pack("m")
      base64.split($/)
    end

    # Returns the _encoded-word_ representation of `str` in `"Q"` encoding
    # (_quoted-printable_).
    #
    # ### Examples
    #
    # ```ruby
    # encoded_word = encoded_word("Thomas Müller", "Q")
    # encoded_word.to_s #=> "?utf-8?Q?Thomas=20M=C3=BCller?="
    # ```
    #
    # ### References
    #
    # See [RFC 2047](https://tools.ietf.org/html/rfc2047) for details about
    # _encoded-words_.
    #
    def encoded_word(str)
      return "" if str.nil? || str.empty?

      charset         = str.encoding.to_s.downcase
      max_word_length = 68 - charset.length
      buffer          = ""
      encoded_word    = ""

      str.each_byte do |b|
        case b
        when 33..60, 62, 64..95, 97..126
          # printable character ('!'..'~', except '=', '?', '_')
          char = b.chr
        else
          # any other character
          char = "=#{hex(b)}"
        end

        if buffer.length + char.length > max_word_length
          # break string into multiple encoded words
          if index = buffer.rindex("=20")
            chunk  = buffer[0..index] + " "
            buffer = buffer[index + 3..-1]
          else
            chunk  = buffer
            buffer = ""
          end
          encoded_word << "=?#{charset}?Q?#{chunk}?="
        end
        buffer << char
      end

      encoded_word << "=?#{charset}?Q?#{buffer}?="
    end

    # Returns the _quoted-printable_ representation of `str` as an array of
    # strings.
    #
    # ### References
    #
    # See [RFC 2045, section 6.7](https://tools.ietf.org/html/rfc2045#section-6.7)
    # for details about _quoted-printable_.
    #
    def quoted_printable(str) 
      return [] if str.nil?
           
      buffer = ""
      lines  = []
        
      0.upto(str.bytesize - 1) do |i|
        char = ""

        case b = str.getbyte(i)
        when 10, 13
          # line feed ('\n') or carriage return ('\r')
          p = str.getbyte(i - 1)

          unless b == 10 && p == 13 || b == 13 && p == 10
            lines << buffer
            buffer = ""
          end

        when 9, 32
          # tab or whitespace
          n = str.getbyte(i + 1)

          if n.nil? || n == 10 || n == 13
            char = "=#{hex(b)}"
          else
            char = b.chr
          end

        when 33..60, 62..126
          # printable character ('!'..'~', except '=')
          char = b.chr

        else
          # any other character
          char = "=#{hex(b)}"
        end

        if buffer.length >= 78 - char.length
          lines << (buffer << "=")
          buffer = ""
        end
        buffer << char
      end


      lines << buffer
    end

    # Returns the hexadecimal representation of `byte`.
    #
    def hex(byte)
      byte.to_s(16).upcase
    end
  end
end
