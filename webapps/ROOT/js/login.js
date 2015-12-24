


function FB_checkLoginState() {
  FB.getLoginStatus(function(response) {
    console.log('statusChangeCallback');
    console.log(response);
    if (response.status === 'connected') {
      FB.api('/me', function(response) {
        console.log(['facebook login', response]);
      });
    } else if (response.status === 'not_authorized') {
      console.log('not authorized - user must log in');
    } else {
      console.log('not logged into facebook');
    }
  });
}

// if user is already logged into facebook, continue on
$(document).on('facebookinit', FB_checkLoginState);
