const readline = require('readline');
var admin = require("firebase-admin");
var serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
	credential: admin.credential.cert(serviceAccount)
});

const rl = readline.createInterface({
	input: process.stdin,
	output: process.stdout
});

rl.question('(Enter number to select option)\n\
1. Give user admin privileges\n\
2. Check if user has admin privileges\n\
3. Remove user\'s admin privileges\n', (option) => {

	switch(option){
		case "1":
			giveAdminPrivileges();
			break;
		case "2":
			checkAdminPrivileges();
			break;
		case "3":
			removeAdminPrivileges();
			break;
		default:
			rl.close();
			process.exit();
	}
});

function giveAdminPrivileges(){
	rl.question('Enter UID to give admin privileges to:', (uid) => {
		console.log('Giving admin privileges to:', uid);
		admin.auth().setCustomUserClaims(uid, {admin: true}).then(() => {
			// The new custom claims will propagate to the user's ID token the
			// next time a new one is issued.
			console.log(uid +" now has admin priviliges");
			process.exit();
		});
		rl.close();
	});
}

function checkAdminPrivileges(){
	console.log("Inside check admin privileges")
	rl.question('Enter UID to check admin privileges of:', (uid) => {
		admin.auth().getUser(uid).then((userRecord) => {
		   // The claims can be accessed on the user record.
		  	console.log(userRecord.customClaims.admin);
		  	if(userRecord.customClaims.admin === true){
		  		console.log(uid +" HAS admin privileges");
		  	}else{
		  		console.log(uid +" does NOT have admin privileges");
		  	}
			process.exit();
		});
		rl.close();
	});
}

function removeAdminPrivileges(){
	rl.question('Enter UID to remove admin privileges from:', (uid) => {
		console.log('Removing admin privileges from:', uid);
		admin.auth().setCustomUserClaims(uid, {}).then(() => {
			// The new custom claims will propagate to the user's ID token the
			// next time a new one is issued.
			console.log(uid +" has had admin priviliges removed.");
			process.exit();
		});
		rl.close();
	});
}