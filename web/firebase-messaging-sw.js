importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyC46lfPFuiZyAZN_xqnIxTEGmCYHlG1hIM",
  authDomain: "flutter-complete-app-d3215.firebaseapp.com",
  projectId: "flutter-complete-app-d3215",
  storageBucket: "flutter-complete-app-d3215.firebasestorage.app",
  messagingSenderId: "748344550395",
  appId: "1:748344550395:web:faee4b71890e51ec36615e",
  measurementId: "G-JR7FF5PRB9",
});

const messaging = firebase.messaging();

// Background message handler
messaging.onBackgroundMessage((message) => {
  console.log("[firebase-messaging-sw.js] Background message received:", message);
});
