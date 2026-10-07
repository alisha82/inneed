const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
admin.initializeApp();

// Haversine formula: https://en.wikipedia.org/wiki/Haversine_formula
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Radius of the earth in km
  const dLat = deg2rad(lat2 - lat1);
  const dLon = deg2rad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c; // Distance in km
}

function deg2rad(deg) {
  return deg * (Math.PI / 180);
}

exports.sendSosNotification = onDocumentCreated("sos_alerts/{alertId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    console.log("No data associated with the event");
    return;
  }

  const alertData = snapshot.data();
  const senderId = alertData.senderId || '';
  const alertLat = alertData.latitude;
  const alertLng = alertData.longitude;
  const senderName = alertData.senderName || 'Someone';
  const emergencyType = alertData.emergencyType || 'SOS Alert';

  if (!alertLat || !alertLng) {
    console.log("Alert does not have valid location coordinates.");
    return;
  }

  try {

    //fetching the tokens and locations of all users
    const usersSnapshot = await admin.firestore().collection('users').get();
    const tokensToSend = [];

    usersSnapshot.forEach((doc) => {
      const userData = doc.data();
      const userId = doc.id;


      //dont get notification to myself
      if (userId === senderId) return;

      const userLat = userData.latitude;
      const userLng = userData.longitude;
      const fcmToken = userData.fcmToken; //make sure tokens are saved in app

      if (userLat && userLng && fcmToken) {
        const distance = calculateDistance(alertLat, alertLng, userLat, userLng);

        //only filter users who are in 5km radius
        if (distance <= 5.0) {
          tokensToSend.push(fcmToken);
        }
      }
    });

    if (tokensToSend.length === 0) {
      console.log("No users found within 5km radius.");
      return;
    }

    //multicast msg send to filter tokens
    const message = {
      notification: {
        title: `🚨 Emergency: ${emergencyType}`,
        body: `${senderName} needs help!`,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        senderId: senderId,
        latitude: String(alertLat),
        longitude: String(alertLng),
      },
      tokens: tokensToSend,
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    console.log("Successfully sent notifications to nearby users:", response.successCount);
  } catch (error) {
    console.error("Error sending targeted SOS notifications:", error);
  }
});