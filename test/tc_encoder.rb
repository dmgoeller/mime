require "test/unit"
require "mime"

class TestEncoder < Test::Unit::TestCase #:nodoc:

  include Mime::Encoder

  def test_encoded_word
    # nil
    assert_equal(encoded_word(nil), "")

    # empty string
    assert_equal(encoded_word(""), "")

    # ascii characters only
    assert_equal(encoded_word("Lorem ipsum"), "=?utf-8?Q?Lorem=20ipsum?=")

    # non-ascii characters
    assert_equal(
      encoded_word("ÄäÖöÜüß"),
      "=?utf-8?Q?=C3=84=C3=A4=C3=96=C3=B6=C3=9C=C3=BC=C3=9F?="
    )
  end

  def test_quoted_printable
    # nil
    assert_equal(quoted_printable(nil), [])

    # empty string
    assert_equal(quoted_printable(""), [""])

    # single line
    assert_equal(quoted_printable("Lorem ipsum"), ["Lorem ipsum"])

    # multiple lines
    assert_equal(
      quoted_printable("Lorem ipsum " * 10),
      [
        "Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum " +
        "Lorem ipsum Lorem ipsum Lorem=",
        " ipsum Lorem ipsum Lorem ipsum Lorem ipsum=20"
      ]
    )

    # non-ascii characters
    s = quoted_printable("ÄäÖöÜüß")
    assert_equal(s, ["=C3=84=C3=A4=C3=96=C3=B6=C3=9C=C3=BC=C3=9F"])
  end

  def test_base64
    # nil
    assert_equal(base64(nil), [])

    # empty string
    assert_equal(base64(""), [])

    # single line
    assert_equal(base64("Lorem ipsum"), ["TG9yZW0gaXBzdW0="])

    # multiple lines
    assert_equal(
      base64("Lorem ipsum" * 10),
      [
        "TG9yZW0gaXBzdW1Mb3JlbSBpcHN1bUxvcmVtIGlwc3VtTG9yZW0gaXBzdW1M",
        "b3JlbSBpcHN1bUxvcmVtIGlwc3VtTG9yZW0gaXBzdW1Mb3JlbSBpcHN1bUxv",
        "cmVtIGlwc3VtTG9yZW0gaXBzdW0="
      ]
    )
  end
end
