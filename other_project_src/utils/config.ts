import firebase from 'firebase/compat/app'
import 'firebase/compat/auth'
import 'firebase/compat/firestore'

const firebaseConfig = {
  apiKey: process.env.EXPO_PUBLIC_FB_API_KEY,
  authDomain: process.env.EXPO_PUBLIC_FB_AUTH_DOMAIN,
  projectId: process.env.EXPO_PUBLIC_FB_PROJECT_ID,
  storageBucket: process.env.EXPO_PUBLIC_FB_STORAGE_BUCKET,
  messagingSenderId: process.env.EXPO_PUBLIC_FB_MESSAGING_SENDER_ID,
  appId: process.env.EXPO_PUBLIC_FB_APP_ID
}

// 既に初期化されていなければ初期化
if (firebase.apps.length === 0) {
  firebase.initializeApp(firebaseConfig)
}

const app = firebase.app()
const auth = firebase.auth()
const db = firebase.firestore()

export { app, auth, db }
