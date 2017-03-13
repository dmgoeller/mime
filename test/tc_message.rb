require "test/unit"
require "mime"

class TestMessage < Test::Unit::TestCase #:nodoc:
  
  include Mime
  
  def test_message_1
    message = Message.new(
      CompositeContent.new(
        "mixed",
        "boundary",
        PlainContent.textual("Lorem ipsum dolor sit amet, ..."),
        AdvancedContent.new(
          PlainContent.binary("..."),
          filename: "foo",
          creation_date: DateTime.new(2017, 1, 1, 1),
          modification_date: DateTime.new(2017, 1, 2, 2),
          read_date: DateTime.new(2017, 2, 1, 3)
        )
      ),
      From: Mailbox.new("a.smith@foo.bar", "Allison Smith"),
      To: Mailbox.new("t.mueller@bar.foo", "Thomas Müller"),
      Subject: "Welcome Thomas"
    )
    
    assert_equal(message.to_s, expected_message)
  end
  
  def test_message_2
    message = Message.new
    message["From"] = Mailbox.new("a.smith@foo.bar", "Allison Smith")
    message["To"] = Mailbox.new("t.mueller@bar.foo", "Thomas Müller")
    message["Subject"] = "Welcome Thomas"
    
    multipart = CompositeContent.new
    multipart.type = "mixed"
    multipart.boundary = "boundary"
    message << multipart
    
    body = PlainContent.textual("Lorem ipsum dolor sit amet, ...")
    multipart << body
     
    attachment = AdvancedContent.new(PlainContent.binary("..."))
    attachment.filename = "foo"
    attachment.creation_date = DateTime.new(2017, 1, 1, 1)
    attachment.modification_date = DateTime.new(2017, 1, 2, 2)
    attachment.read_date = DateTime.new(2017, 2, 1, 3)
    multipart << attachment
    
    assert_equal(message.to_s, expected_message)  
  end
    
  def expected_message
    <<EOS
MIME-Version: 1.0
From: Allison Smith <a.smith@foo.bar>
To: =?utf-8?Q?Thomas=20M=C3=BCller?= <t.mueller@bar.foo>
Subject: Welcome Thomas
Content-Type: multipart/mixed; boundary="=_boundary"

--=_boundary
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Lorem ipsum dolor sit amet, ...
--=_boundary
Content-Disposition: attachment; filename=foo;
 creation-date="Sun, 01 Jan 2017 01:00:00 +0000";
 modification-date="Mon, 02 Jan 2017 02:00:00 +0000";
 read-date="Wed, 01 Feb 2017 03:00:00 +0000"; size=3
Content-Type: application/octet-stream
Content-Transfer-Encoding: base64

Li4u
--=_boundary--
EOS
  end
  
end