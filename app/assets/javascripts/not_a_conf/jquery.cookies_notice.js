(function($) {
  jQuery.fn.cookieNotice = function(options) {
    if (getCookie('cookiesAccepted')) {
      return this;
    }

    var settings = $.extend(
      {
        title: 'Cookies & Privacy',
        message:
        'This site uses cookies to personalize content.<br />We share your data with third party services for analytics.',
        delay: 1000,
        expires: 3600,
        acceptBtnLabel: 'Accept Cookies',
      },
      options,
    );

    var $element = $(this);
    setTimeout(function() {
      $element
        .on('click', '#gdpr-cookie-accept', function() {
          setCookie('cookiesAccepted', true, settings.expires);
          $element.find('#gdpr-cookie-message').remove();
        })
        .append(
          '<div id="gdpr-cookie-message"><h4>' +
            settings.title +
            '</h4><p>' +
            settings.message +
            '</p><button id="gdpr-cookie-accept" type="button">' +
            settings.acceptBtnLabel +
            '</button></div>',
        )
        .find('#gdpr-cookie-message')
        .hide()
        .fadeIn('slow');
    }, settings.delay);

    return this;
  };

  function setCookie(name, value, expiry_days) {
    var d = new Date();
    d.setTime(d.getTime() + expiry_days * 24 * 60 * 60 * 1000);
    document.cookie =
      name + '=' + value + ';expires=' + d.toUTCString() + ';path=/';
  }

  function getCookie(name) {
    var cookieName = name + '=';
    var decodedCookie = decodeURIComponent(document.cookie);
    var ca = decodedCookie.split(';');
    for (var i = 0; i < ca.length; i++) {
      var c = ca[i];
      while (c.charAt(0) == ' ') {
        c = c.substring(1);
      }
      if (c.indexOf(cookieName) === 0) {
        return c.substring(cookieName.length, c.length);
      }
    }
    return false;
  }
})(jQuery);
