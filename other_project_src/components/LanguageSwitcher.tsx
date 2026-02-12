import React from 'react'
import { TouchableOpacity, Text, StyleSheet, View } from 'react-native'
import { Ionicons } from '@expo/vector-icons'
import { useLanguage } from '../hooks/useLanguage'
import { colors, spacing, fontSize } from '../utils/theme'

const LanguageSwitcher = (): React.ReactElement => {
  const { currentLanguage, toggleLanguage } = useLanguage()

  return (
    <TouchableOpacity
      style={styles.container}
      onPress={toggleLanguage}
    >
      <Ionicons name="globe-outline" size={20} color={colors.primary} />
      <Text style={styles.languageText}>
        {currentLanguage.toUpperCase()}
      </Text>
    </TouchableOpacity>
  )
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    marginRight: spacing.sm
  },
  languageText: {
    fontSize: fontSize.sm,
    fontWeight: '600',
    color: colors.primary,
    marginLeft: spacing.xs
  }
})

export default LanguageSwitcher
