require "test/unit"
require "mime"

class TestMailbox < Test::Unit::TestCase #:nodoc:

  include Mime

  def test_mailbox
    # nil
    mailbox = Mailbox.new(nil)
    assert_equal(mailbox.to_s, "")

    # empty string
    mailbox = Mailbox.new("")
    assert_equal(mailbox.to_s, "")

    # addr spec
    mailbox = Mailbox.new("a.smith@foo.bar")
    assert_equal(mailbox.to_s, "a.smith@foo.bar")

    # addr spec enclosed in angle brackets
    mailbox = Mailbox.new("<a.smith@foo.bar>")
    assert_equal(mailbox.to_s, "<a.smith@foo.bar>")

    # display name
    mailbox = Mailbox.new("a.smith@foo.bar", "Allison Smith")
    assert_equal(mailbox.to_s, "Allison Smith <a.smith@foo.bar>")
    assert_equal(mailbox.to_s(true), "Allison Smith <a.smith@foo.bar>")

    # non-ascii characters
    mailbox = Mailbox.new("t.mueller@foo.bar", "Thomas Müller")
    assert_equal(mailbox.to_s, "Thomas Müller <t.mueller@foo.bar>")
    assert_equal(mailbox.to_s(true), "=?utf-8?Q?Thomas=20M=C3=BCller?= <t.mueller@foo.bar>")
  end
end
