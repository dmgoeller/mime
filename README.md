# Ruby MIME Library

This library provides classes for composing MIME messages. Together with the
built-in `Net::SMTP` module it could be used to create and send emails. This
library does not support parsing emails.

## Content-oriented Structure

It seems to be obvious to represent MIME messages and message parts by objects
holding a header field map and a body. Because some header fields relate to
the body of a message or a message part, it is mostly necessary to update one
or more header fields when changing the body. Note that the `Content-Type`
header field must be changed when a plain text body is replaced by an HTML
body. That's why this library has a content-oriented structure instead of the
structure described before. For example, a simple plain text message is
represented by a `Message` object and a `PlainContent` object associated with
the `Message` instance. The `Message` object holds common header fields such
as `From`, `To`, and `Subject`, where the `PlainContent` object specifies
content-related header fields such as `Content-Type` and
`Content-Transfer-Encoding`.

### Classes:

![Classes](/doc/images/classes.png)

## Examples

The following example demonstrates how to compose a message containing a plain
text body and a binary attachment:

```ruby
include Mime

message = Message.new(PlainContent.textual("Lorem ipsum dolor sit amet, ..."))
message["From"]    = Mailbox.new("a.smith@foo.com", "Allison Smith")
message["To"]      = Mailbox.new("t.mueller@bar.com", "Thomas Müller")
message["Subject"] = "Welcome"

attachment = PlainContent.binary("Lorem ipsum dolor sit amet, ...")
message << AdvancedContent.new(attachment, filename: "foo.bar")
```

Produces:

```
MIME-Version: 1.0
From: Allison Smith <a.smith@foo.com>
To: =?utf-8?Q?Thomas=20M=C3=BCller?= <t.mueller@bar.com>
Subject: Welcome
Content-Type: multipart/mixed; boundary="=_14c12a0"

--=_14c12a0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Lorem ipsum dolor sit amet, ...
--=_14c12a0
Content-Disposition: attachment; filename="foo.bar"; size=31
Content-Type: application/octet-stream
Content-Transfer-Encoding: base64

TG9yZW0gaXBzdW0gZG9sb3Igc2l0IGFtZXQsIC4uLg==
  --=_14c12a0--
```

The following example illustrates how to create and send an email using
the `Net::SMTP` module:

```ruby
include Mime

message = Message.new(PlainContent.textual("..."))
# ...

smtp = Net::SMTP.new(...)
# ...
smtp.data { |io| message.write(io) }
# ...
```

## References

* [RFC 2045](https://tools.ietf.org/html/rfc2045) Multipurpose Internet Mail
  Extensions (MIME) Part One: Format of Internet Message Bodies
* [RFC 2046](https://tools.ietf.org/html/rfc2046) Multipurpose Internet Mail
  Extensions (MIME) Part Two: Media Types Multipurpose Internet
* [RFC 2047](https://tools.ietf.org/html/rfc2047) Multipurpose Internet Mail
  Extensions (MIME) Part Three: Message Header Extensions for Non-ASCII Text
* [RFC 2183](https://tools.ietf.org/html/rfc2183) Communicating Presentation
  Information in Internet Messages: The Content-Disposition Header Field
* [RFC 5322](https://tools.ietf.org/html/rfc5322) Internet Message Format
