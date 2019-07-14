var config = {
    apiKey: "AIzaSyA0GG69qiEoiJVJI7DHBxmbqjsz4eJHdQo",
    authDomain: "twistr-cd503.firebaseapp.com",
    databaseURL: "https://twistr-cd503.firebaseio.com",
    projectId: "twistr-cd503",
    storageBucket: "twistr-cd503.appspot.com",
    messagingSenderId: "805585132467"
 };
firebase.initializeApp(config);

function loginWithFacebook(){
	var provider = new firebase.auth.FacebookAuthProvider();
	return firebase.auth().signInWithPopup(provider);
}

function checkUserAdmin(){
	return firebase.auth().currentUser.getIdToken().then(idToken => {
		const payload = JSON.parse(b64DecodeUnicode(idToken.split('.')[1]));
	   // Confirm the user is an Admin.
	   return payload['admin'];
	});
}

function signout(){
	firebase.auth().signOut().then(function() {
	  // Sign-out successful.
	}).catch(function(error) {
	  console.log("Error logging out:")
	  console.log(error);
	});
}

function loadAnalytics(){
	var url = "https://console.firebase.google.com/project/"+config.projectId+"/analytics/overview";
	window.open(url,'_blank');
}

function b64DecodeUnicode(str) {
    // Going backwards: from bytestream, to percent-encoding, to original string.
    return decodeURIComponent(atob(str).split('').map(function(c) {
        return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
    }).join(''));
}

function isObject(val) {
    if (val === null) { return false;}
    return ( (typeof val === 'function') || (typeof val === 'object') );
}
