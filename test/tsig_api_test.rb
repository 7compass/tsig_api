require File.join(File.dirname(__FILE__), '/test_helper')

class TsigApiTest < ActiveSupport::TestCase

  def test_text_from_flash
    str = "
    <div id=\\'error-message-container\\'><div class=\\'flash error\\'>
    <a class=\\\"float-right small-text\\\" href=\\\"#\\\" onclick=\\\"hideErrorMessage(); return false;\\\">[Hide this]</a>
    <div class=\\\"message-title\\\"><span class=\\\"error-icon\\\">!</span></div>
    <div class=\\\"message-contents\\\">Please correct the following error(s):
    <ul><li>Please make one or more selections for Teams.</li></ul></div>
    <div class=\\\"clear\\\">&nbsp;</div></div></div>
    "
    assert_equal ['Please make one or more selections for Teams.'], TsigApi::text_from_flash(str)

    str = "
    <div id=\\'error-message-container\\'><div class=\\'flash error\\'>
    <a class=\\\"float-right small-text\\\" href=\\\"#\\\" onclick=\\\"hideErrorMessage(); return false;\\\">[Hide this]</a>
    <div class=\\\"message-title\\\"><span class=\\\"error-icon\\\">!</span></div>
    <div class=\\\"message-contents\\\">Please correct the following error(s):
    <ul><li>First message</li> <li>Second message</li>
    <li>Third</li></ul></div>
    <div class=\\\"clear\\\">&nbsp;</div></div></div>
    "
    assert_equal ['First message', 'Second message', 'Third'], TsigApi::text_from_flash(str)

    str = "
    <div id=\\'error-message-container\\'><div class=\\'flash error\\'>
    <a class=\\\"float-right small-text\\\" href=\\\"#\\\" onclick=\\\"hideErrorMessage(); return false;\\\">[Hide this]</a>
    <div class=\\\"message-title\\\"><span class=\\\"error-icon\\\">!</span></div>
    <div class=\\\"message-contents\\\">Please correct the following error(s):</div>
    <div class=\\\"clear\\\">&nbsp;</div></div></div>
    "
    assert_equal [], TsigApi::text_from_flash(str)
  end

end
