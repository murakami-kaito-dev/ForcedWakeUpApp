import React, { useEffect, useState } from 'react'
import { View, ActivityIndicator, StyleSheet } from 'react-native'
import { Stack } from 'expo-router'
import { useTranslation } from 'react-i18next'
import { initI18n } from '../i18n'
import { colors } from '../utils/theme'

const Layout = (): React.ReactElement => {
  const { t } = useTranslation()
  const [i18nReady, setI18nReady] = useState(false)

  useEffect(() => {
    initI18n()
      .then(() => { setI18nReady(true) })
      .catch(() => { setI18nReady(true) })
  }, [])

  if (!i18nReady) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={colors.primary} />
      </View>
    )
  }

  return <Stack
    screenOptions={() => ({
      headerStyle: {
        backgroundColor: colors.background
      },
      headerTintColor: colors.primary,
      headerTitle: '',
      headerBackTitle: t('common.back'),
      headerShadowVisible: false
    })}/>
}

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: colors.background
  }
})

export default Layout
