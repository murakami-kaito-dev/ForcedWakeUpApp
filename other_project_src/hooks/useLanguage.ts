import { useState, useCallback } from 'react'
import { useTranslation } from 'react-i18next'
import { changeLanguage, getCurrentLanguage } from '../i18n'

interface UseLanguageReturn {
  currentLanguage: string
  toggleLanguage: () => Promise<void>
  isJapanese: boolean
  isEnglish: boolean
}

export const useLanguage = (): UseLanguageReturn => {
  const { i18n } = useTranslation()
  const [currentLanguage, setCurrentLanguage] = useState(getCurrentLanguage())

  const toggleLanguage = useCallback(async () => {
    const newLanguage = currentLanguage === 'ja' ? 'en' : 'ja'
    await changeLanguage(newLanguage)
    setCurrentLanguage(newLanguage)
  }, [currentLanguage])

  return {
    currentLanguage: i18n.language || currentLanguage,
    toggleLanguage,
    isJapanese: (i18n.language || currentLanguage) === 'ja',
    isEnglish: (i18n.language || currentLanguage) === 'en'
  }
}

export default useLanguage
