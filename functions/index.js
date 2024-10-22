/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {setGlobalOptions} = require("firebase-functions/v2");
const {getMessaging} = require("firebase-admin/messaging");
const logger = require("firebase-functions");
initializeApp();
const msg = getMessaging();
setGlobalOptions({maxInstances: 10});

exports.sendOrderNotification = onDocumentCreated("Orders/{id}", (event) => {
  const topic = "order";
  const id = event.params.id;
  const payload = {
    notification: {
      title: "New Order",
      body: "You have a new order!",
    },
    data: {
      key: "neworder",
      value: id,
    },
    topic: topic,
  };
  msg.send(payload)
      .then((response) => {
        logger.log("order message send");
      })
      .catch((error) => {
        logger.log("Error occured", error);
      });
});
