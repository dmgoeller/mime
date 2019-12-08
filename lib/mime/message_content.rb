require "date"
require "forwardable"
require "stringio"

module Mime

  # (Abstract) superclass of all classes that represent a message content.
  # Subclasses of `MessageContent` must override the `#write` method to
  # write the message content's MIME representation to an output stream.
  #
  class MessageContent

    include Encoder

    # Writes the MIME representation of the message content to an underlying
    # output stream.
    #
    def write(*)
      raise "abstract method invoked: #write."
    end

    # Returns the MIME representation of the message content as a string.
    #
    def to_s
      io = StringIO.new
      write(io)
      io.string
    end

    private

    # Utility class for writing the MIME representation of a message content
    # to an underlying output stream.
    #
    class Writer

      include Encoder
      extend  Forwardable

      # Date-time format as specified by RFC 5322, section 3.3.
      #
      DATE_TIME_FORMAT = "%a, %d %b %Y %H:%M:%S %z".freeze

      # Returns a `Writer` that encapsulates the specified `IO`</tt>` object.
      #
      def Writer.get(io)
        io.is_a?(Writer) ? io : Writer.new(io)
      end

      # Creates a `Writer` that encapsulates the specified `IO` object.
      #
      def initialize(io)
        @io   = io
        @path = []
      end

      # Delegate calls of instance methods inherited from `IO` to the
      # encapsulated `IO` object.
      #
      def_delegators :@io, *(IO.instance_methods - Object.instance_methods)

      # Writes the specified line of text to the underlying output stream.
      #
      def write_line(line = "")
        puts(line)
      end

      # Writes the specified header field to the underlying output stream.
      #
      def write_header_field(name, value, param = {})
        return if name.empty? || value.nil?

        # name and value
        header_field = "#{name}: #{format(value)}"

        # parameters
        param.each do |param_name, param_value|
          # format parameter value
          if param_value.is_a?(Date)
            param_value = param_value.strftime(DATE_TIME_FORMAT)
          else
            param_value = String.new(param_value.to_s)
          end

          # quote parameter value if necessary
          if param_value.start_with?("\"")
            param_value.slice!(0)
            param_value.slice!(-1) if param_value.end_with?("\"")
            quote = true
          else
            quote = param_value.include?(" ") || param_value.include?(";")
          end

          # escape double quote characters
          param_value.sub!("\"", "\\\"")

          if quote
            header_field << "; #{param_name}=\"#{param_value}\""
          else
            header_field << "; #{param_name}=#{param_value}"
          end
        end

        # write header field
        if header_field.length < 79
          puts(header_field)
        else
          fold(header_field)
        end
      end

      # Writes the specified message content to the underlying output stream.
      #
      def write_content(content)
        # ensure that @path does not contain the given message content
        raise "circular object reference detected." if @path.include?(content)

        # add the given message content to @path
        @path.push(content)

        # write the given message content
        if content.is_a?(Message)
          write_header_field("Content-Type", "message/rfc822")
          write_line
        end

        content.write(self)

        # remove the given message content from @path
        @path.pop
      end

      private

      # Returns the MIME-compliant representation of the specified value.
      #
      def format(value)
        result = ""

        if value.is_a?(Time) || value.is_a?(Date)
          # time, date, or date-time
          result = value.strftime(DATE_TIME_FORMAT)

        elsif value.is_a?(Mailbox)
          # mailbox
          result = value.to_s(true)

        elsif value.is_a?(Array)
          # e.g. mailbox list
          value.each do |element|
            result << ", " unless result.empty?

            if element.is_a?(Mailbox)
              result << element.to_s(true)
            else
              result << element.to_s
            end
          end

        else
          # any other object
          result = value.to_s
          result = encoded_word(result) unless result.ascii_only?
        end

        result
      end

      # "Folds" the specified header field as described in RFC 5322,
      # section 2.2.3.
      #
      def fold(header_field)
        start_at = 0
        fwsp     = {}

        0.upto(header_field.length - 1).each do |index|
          if header_field[index] == " "
            # folding whitespace
            case header_field[index - 1]
            when ";" then fwsp[3] = index # strongest
            when "," then fwsp[2] = index #
            else          fwsp[1] = index # weakest
            end
          end

          if index - start_at > 77 && !fwsp.empty?
            # write next line
            break_before = fwsp[fwsp.keys.max]

            puts(header_field[start_at..(break_before - 1)])

            start_at = break_before
            fwsp.clear
          end
        end

        # write last line
        puts(header_field[start_at..-1]) if start_at < header_field.length - 1
      end
    end
  end
end
