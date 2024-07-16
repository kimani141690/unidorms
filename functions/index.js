const functions = require('firebase-functions');
const admin = require('firebase-admin');
const express = require('express');
const dotenv = require('dotenv');
const app = express();

// Load environment variables from .env file
dotenv.config();

admin.initializeApp();

app.use(express.json());

app.post('/payment_callback', (req, res) => {
  const paymentData = req.body;

  // Process the payment data
  console.log('Payment Data:', paymentData);

  // Save payment data to Firestore or perform other actions here
  const paymentRef = admin.firestore().collection('payments').doc(paymentData.MerchantRequestID);
  paymentRef.set(paymentData, { merge: true })
    .then(() => {
      res.status(200).send('Callback received');
    })
    .catch((error) => {
      console.error('Error saving payment data:', error);
      res.status(500).send('Error processing payment data');
    });
});

exports.api = functions.https.onRequest(app);
