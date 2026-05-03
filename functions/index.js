/**
 * Deploy (from repo root): `cd functions && npm install && cd .. && firebase deploy --only functions`
 *
 * Topic `chef_alerts` must match `kChefAlertsTopic` in lib/services/push_registration_service.dart
 */
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const {
  onDocumentCreated,
  onDocumentUpdated,
} = require('firebase-functions/v2/firestore');

initializeApp({});

const db = getFirestore();
const messaging = getMessaging();

const CHEF_ALERTS_TOPIC = 'chef_alerts';

function trimItem(text) {
  const s = (text ?? '').toString().trim().slice(0, 100);
  return s.length ? s : 'New catering request';
}

async function notifyTopicNewRequest(title, body) {
  await messaging.send({
    notification: { title, body },
    topic: CHEF_ALERTS_TOPIC,
    android: { priority: 'high' },
  });
}

exports.onFoodOrderCreated = onDocumentCreated('food_orders/{orderId}', async (event) => {
  const snap = event.data;
  if (!snap) return;

  const d = snap.data();
  const item = trimItem(d.itemName);

  await notifyTopicNewRequest('New catering request', `${item}`);
});

exports.onRequestDocCreated = onDocumentCreated('requests/{requestId}', async (event) => {
  const snap = event.data;
  if (!snap) return;

  const d = snap.data();
  const item = trimItem(d.Item_Name || d.itemName);

  await notifyTopicNewRequest('New request posted', `${item}`);
});

exports.onChefAssignedToFoodOrder = onDocumentUpdated('food_orders/{orderId}', async (event) => {
  const change = event.data;
  if (!change || !change.after.exists) return;

  const before = change.before.exists ? change.before.data() ?? {} : {};
  const after = change.after.data() ?? {};

  const newChief = String(after.acceptedChiefId ?? '');
  const oldChief = String(before.acceptedChiefId ?? '');

  if (!newChief || newChief === 'noChiefSelected' || newChief === oldChief) return;

  const chefDoc = await db.collection('allusers').doc(newChief).get();
  if (!chefDoc.exists) return;

  const token = chefDoc.get('fcmToken');
  if (!token || typeof token !== 'string') {
    console.log('Assigned chef missing fcmToken', newChief);
    return;
  }

  const item = trimItem(after.itemName);

  await messaging.send({
    notification: {
      title: 'Order assigned to you',
      body: item,
    },
    token,
    android: { priority: 'high' },
  });
});
