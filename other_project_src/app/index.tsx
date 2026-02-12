import React, { useEffect } from 'react'
import { View, ActivityIndicator, StyleSheet } from 'react-native'
import { router } from 'expo-router'
import { auth } from '../utils/config'
import anonymousLogin from '../components/AnonymousLogin'

const Index = (): React.ReactElement => {
  useEffect(() => {
    anonymousLogin()
      .then(() => {})
      .catch(() => {})

    const unsubscribe = auth.onAuthStateChanged((user) => {
      if (user !== null) {
        router.replace('screens/home')
      }
    })

    return () => { unsubscribe() }
  }, [])

  return (
    <View style={styles.container}>
      <ActivityIndicator size="large" color="#4A90D9" />
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5F5F5'
  }
})

export default Index
