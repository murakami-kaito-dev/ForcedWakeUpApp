import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import * as Localization from 'expo-localization'
import AsyncStorage from '@react-native-async-storage/async-storage'

import ja from './locales/ja.json'
import en from './locales/en.json'

const LANGUAGE_KEY = '@app_language'

const resources = {
  ja: { translation: ja },
  en: { translation: en }
}

const getDeviceLanguage = (): string => {
  const deviceLocale = Localization.getLocales()[0]?.languageCode
  if (deviceLocale === 'ja' || deviceLocale === 'en') {
    return deviceLocale
  }
  return 'ja'
}

export const initI18n = async (): Promise<void> => {
  let savedLanguage: string | null = null
  try {
    savedLanguage = await AsyncStorage.getItem(LANGUAGE_KEY)
  } catch (error) {
    console.log('Failed to load language setting:', error)
  }

  const initialLanguage = savedLanguage ?? getDeviceLanguage()

  await i18n
    .use(initReactI18next)
    .init({
      resources,
      lng: initialLanguage,
      fallbackLng: 'ja',
      interpolation: {
        escapeValue: false
      },
      react: {
        useSuspense: false
      }
    })
}

export const changeLanguage = async (language: string): Promise<void> => {
  try {
    await AsyncStorage.setItem(LANGUAGE_KEY, language)
    await i18n.changeLanguage(language)
  } catch (error) {
    console.log('Failed to change language:', error)
  }
}

export const getCurrentLanguage = (): string => {
  return i18n.language || 'ja'
}

export default i18n
