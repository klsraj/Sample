'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
var FB = require('fb');
var rp = require('request-promise');
const cors = require('cors');
admin.initializeApp();
const gcs = require('@google-cloud/storage')();
const mkdirp = require('mkdirp-promise');
const spawn = require('child-process-promise').spawn;
const path = require('path');
const os = require('os');
const fs = require('fs');

const appleIAPSecret = "YOUR_APPLE_IAP_SECRET";


exports.userBanned = functions.database.ref('/users/{userId}/banned').onWrite((change, context) => {
	const userId = context.params.userId;
	const banned = Boolean(change.after.val());
	
	return banUserPromise = admin.auth().updateUser(userId, {
		disabled : banned
	}).then(results => {
		return console.log("User has been banned", userId);
	});
});

exports.receiptValidationRequest = functions.database.ref('receipt_validation/req/{req_id}').onCreate((snapshot, context) => {
	const req_id = context.params.req_id;
	const receipt_data = snapshot.val();
	const deleteReq = snapshot.ref.remove();

	return validateReceipt(receipt_data, true).then(function(response){
		console.log(response);
		const addResponse = snapshot.ref.parent.parent.child('rec/'+req_id).set(response);
		return Promise.all([deleteReq, addResponse]);
	}).catch(function(error){
		console.log("Error validating receipt");
		console.log(error);
		const addResponse = snapshot.ref.parent.parent.child('rec/'+req_id).set(false);
		return Promise.all([deleteReq, addResponse]);
	});

});

function validateReceipt(receipt_data, production = true){
	var options = {
		method: 'POST',
		uri: (production ? 'https://buy.itunes.apple.com/verifyReceipt' : 'https://sandbox.itunes.apple.com/verifyReceipt'),
		body:{
			'receipt-data' : receipt_data,
			'password' : appleIAPSecret,
			'exclude-old-transactions' : true
		},
		json: true
	}

	return rp(options)
		.then(function(response){
			if(production === true && response.status == 21007){
				return validateReceipt(receipt_data, false);
			}
			return response;
		})
		.catch(function(error){
			return error;
		});
}

exports.newMessage = functions.database.ref('messages/{chat_id}/{message_id}').onCreate((snapshot, context) => {
	const data = snapshot.val();
	const receiver_id = data.receiver_id;
	const message_type = data.type;

	return incrementBadgeCount(receiver_id).then(result =>{
		var payload;
		if(message_type == "image"){
			payload = {
		      notification: {
		        'title_loc_key' : 'NOTIFICATION_NEW_IMAGE_MESSAGE_TITLE',
		        'title_loc_args' : JSON.stringify([data.sender_name]),
		        'body_loc_key' : 'NOTIFICATION_NEW_IMAGE_MESSAGE_BODY',
		        'body_loc_args' : JSON.stringify([data.sender_name]),
		        'badge' : result.snapshot.val() + '',
		        'sound': 'NewMessage.mp3'
		      }
		    };
		}else if(message_type == "location"){
			payload = {
		      notification: {
		        'title_loc_key' : 'NOTIFICATION_NEW_LOCATION_MESSAGE_TITLE',
		        'title_loc_args' : JSON.stringify([data.sender_name]),
		        'body_loc_key' : 'NOTIFICATION_NEW_LOCATION_MESSAGE_BODY',
		        'body_loc_args' : JSON.stringify([data.sender_name]),
		        'badge' : result.snapshot.val() + '',
		        'sound': 'NewMessage.mp3'
		      }
		    };
		}else{
			payload = {
		      notification: {
		        'title_loc_key' : 'NOTIFICATION_NEW_MESSAGE_TITLE',
		        'title_loc_args' : JSON.stringify([data.sender_name, data.text]),
		        'body_loc_key' : 'NOTIFICATION_NEW_MESSAGE_BODY',
		        'body_loc_args' : JSON.stringify([data.sender_name, data.text]),
		        'badge' : result.snapshot.val() + '',
		        'sound': 'NewMessage.mp3'
		      }
		    };
		}
		return sendNotification(receiver_id, payload, 'messageNotifications');
	});
});

function incrementBadgeCount(user_id){
	var badgeCountRef = admin.database().ref('badge_count/'+user_id);
	return badgeCountRef.transaction(function(current_value){
		return (current_value || 0) + 1;
	});
}

exports.userLiked = functions.database.ref('user_likes/{swiper_id}/{swiped_id}').onCreate((snapshot, context) => {
	const swiper_id = context.params.swiper_id;
	const swiped_id = context.params.swiped_id;

	console.log("User liked, checking for match");

	return admin.database().ref('user_likes/' + swiped_id + '/' + swiper_id).once('value').then(snap => {

		if(snap.exists()){
			//Users like eachother, create match
			var genChatId = admin.database().ref('chats').push();
			//var removeUserLike = admin.database().ref('user_likes/' + swiper_id + '/' + swiped_id).remove();
			//var removeOpponentLike = admin.database().ref('user_likes/' + swiped_id + '/' + swiper_id).remove();
			var updates = {};
			updates['user_likes/' + swiper_id + '/' + swiped_id] = null;
			updates['user_likes/' + swiped_id + '/' + swiper_id] = null;
			updates['pending_likes/' + swiper_id + '/' + swiped_id] = null;
			updates['pending_likes/' + swiped_id + '/' + swiper_id] = null;
			updates['super_likes/' + swiper_id + '/' + swiped_id] = null;
			updates['super_likes/' + swiped_id + '/' + swiper_id] = null;
			var removeLikes = admin.database().ref().update(updates);

			return Promise.all([genChatId, removeLikes]).then( results => {
				var chat_id = results[0].key;
				var updates = {};
				updates['user_chats/' + swiper_id + '/' + chat_id] = true;
				updates['user_chats/' + swiped_id + '/' + chat_id] = true;

				var chat = {
					occupants : {},
					created_at : admin.database.ServerValue.TIMESTAMP,
					updated_at : admin.database.ServerValue.TIMESTAMP
				}
				chat.occupants[swiper_id] = 1;
				chat.occupants[swiped_id] = 1;

				updates['chats/' + chat_id] =  chat
				return admin.database().ref().update(updates).then(result => {

					return Promise.all([
			    		incrementBadgeCount(swiped_id),
			    		incrementBadgeCount(swiper_id)
			    	]).then(results =>{
			    		
			    		const swiped_payload = {
					      notification: {
					        'title_loc_key': 'NOTIFICATION_NEW_MATCH_TITLE',
					        'body_loc_key' : 'NOTIFICATION_NEW_MATCH_BODY',
					        'badge' : results[0].snapshot.val() + '',
					        'sound': "NewMatch.mp3"
					      }
					    };

					    const swiper_payload = {
					      notification: {
					        'title_loc_key': 'NOTIFICATION_NEW_MATCH_TITLE',
					        'body_loc_key' : 'NOTIFICATION_NEW_MATCH_BODY',
					        'badge' : results[1].snapshot.val() + '',
					        'sound': "NewMatch.mp3"
					      }
					    };

					    return Promise.all([
					    	sendNotification(swiped_id, swiped_payload, 'matchNotifications'), 
							sendNotification(swiper_id, swiper_payload, 'matchNotifications')
					    ]);
			    	});
				});
			});
		}else{
			return console.log("No mutal match");
		}
	});
});

exports.chatDeleted = functions.database.ref('chats/{chat_id}').onDelete((snapshot, context) => {
	if(snapshot.exists()){
		return deleteChat(context.params.chat_id, snapshot.val());
	}else{
		return console.log("Chat already deleted");
	}
});

exports.userChatDeleted = functions.database.ref('user_chats/{user_id}/{chat_id}').onDelete((snapshot, context) => {
	const chat_id = context.params.chat_id;
	return admin.database().ref('/chats/'+chat_id).once('value').then(snap => {
		if(snap.exists()){
			return deleteChat(chat_id, snap.val());
		}else{
			return console.log("Chat already deleted");
		}
	});
});

exports.userCreated = functions.auth.user().onCreate(user => {
	const user_id = user.uid;

	if(user_id.length == 0){
		return console.log("UID not valid");
	}

	return admin.database().ref('/users/'+user_id+'/created_at').set(admin.database.ServerValue.TIMESTAMP);
});

exports.userRecordDeleted = functions.database.ref('users/{user_id}').onDelete((snapshot, context) => {
	const userId = context.params.user_id;
	const firebaseConfig = JSON.parse(process.env.FIREBASE_CONFIG);
	const bucket = gcs.bucket(firebaseConfig.storageBucket);
	
	if(userId.length == 0){
    	return console.log("Invalid user_id");
    }else{
	    return bucket.deleteFiles({
	  		prefix: 'user_profile_images/'+userId
		}).then(function(){
			return admin.auth().deleteUser(userId).then(function() {
			    console.log("Successfully deleted user");
			})
			.catch(function(error) {
				return console.log("Error deleting user:", error);
			});
		});
	}
});

exports.userDeleted = functions.auth.user().onDelete(user => {

	const user_id = user.uid;

	if(!user_id || user_id.length == 0){
		return console.log("UID not valid");
	}

	var updates = {};
	updates['pending_likes/'+user_id] = null;
	updates['reports/'+user_id] = null;
	updates['reports_summary/'+user_id] = null;
	updates['super_likes/'+user_id] = null;
	updates['user_chats/'+user_id] = null;
	updates['user_likes/'+user_id] = null;
	updates['user_settings/'+user_id] = null;
	updates['user_swipes/'+user_id] = null;
	updates['user_tokens/'+user_id] = null;
	updates["users/"+user_id] = null;
	updates['geo/f_f/'+user_id] = null;
	updates['geo/f_m/'+user_id] = null;
	updates['geo/m_f/'+user_id] = null;
	updates['geo/m_m/'+user_id] = null;

	return admin.database().ref().update(updates).then( result => {
		return console.log("User cleaned up!");
	});

});

// Helper Functions

function deleteChat(chat_id, chat_data){
	if(chat_id.length == 0){
		return console.log("No chat ID given.");
	}
	var updates = {};
	updates['chats/' + chat_id] = null;
	updates['messages/' + chat_id] = null;
	var occupants = Object.keys(chat_data.occupants);
	for(var i = 0; i < occupants.length; i++){
		if(occupants[i].length == 0){
			continue;
		}
		updates['user_chats/' + occupants[i] + '/' + chat_id] = null;
	}
	return admin.database().ref().update(updates).then( result => {
		console.log("Chat deleted");
		const firebaseConfig = JSON.parse(process.env.FIREBASE_CONFIG);
		const bucket = gcs.bucket(firebaseConfig.storageBucket);
		return bucket.deleteFiles({
	  		prefix: 'chat_uploads/'+chat_id
		}).then(function(){
			return console.log("Chat images deleted");
		});
	});
}

function sendNotification(user_id, payload, settingsRef){

	// const tokensPromise = admin.database().ref('/user_tokens/'+user_id).once('value');
	const settingsPromise = admin.database().ref('/user_settings/'+user_id+'/'+settingsRef).once('value');
	const tokensPromise = admin.database().ref('/user_tokens/'+user_id).once('value');
  	return Promise.all([settingsPromise, tokensPromise]).then(results => {

	  	const shouldSendNotification = results[0].exists() ? results[0].val() : true;
	  	if(!shouldSendNotification){
	  		return console.log("Not sending notification due to user settings");
	  	}

	  	const tokensSnapshot = results[1];
	  	if (!tokensSnapshot.hasChildren()) {
	      return console.log('There are no notification tokens to send to.');
	    }

	    console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');
	  	const tokens = Object.keys(tokensSnapshot.val());

	  	// Send notifications to all tokens.
	    return admin.messaging().sendToDevice(tokens, payload).then(response => {
	      // For each message check if there was an error.
	      const tokensToRemove = [];
	      response.results.forEach((result, index) => {
	        const error = result.error;
	        if (error) {
	          console.error('Failure sending notification to', tokens[index], error);
	          // Cleanup the tokens who are not registered anymore.
	          if (error.code === 'messaging/invalid-registration-token' ||
	              error.code === 'messaging/registration-token-not-registered') {
	            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
	          }
	        }
	      });
	      return Promise.all(tokensToRemove);
	    });
  	});
}