// Minimal Firebase Messaging service worker entry.
// This file must exist at /firebase-messaging-sw.js for web FCM registration.
self.addEventListener('install', () => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});
