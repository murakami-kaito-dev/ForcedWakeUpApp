import React from 'react'
import { Text, StyleSheet, TouchableOpacity } from 'react-native'
import { useTranslation } from 'react-i18next'
import { colors, spacing, fontSize } from '../utils/theme'

interface Props {
  onSave: () => void
  disabled?: boolean
}

const Save = (props: Props): React.ReactElement => {
  const { t } = useTranslation()
  const { onSave, disabled = false } = props
  return (
    <TouchableOpacity
      style={[styles.saveButton, disabled && styles.saveButtonDisabled]}
      onPress={onSave}
      disabled={disabled}
    >
      <Text style={[styles.saveText, disabled && styles.saveTextDisabled]}>{t('common.save')}</Text>
    </TouchableOpacity>
  )
}

const styles = StyleSheet.create({
  saveButton: {
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    borderRadius: 8,
    backgroundColor: colors.primary
  },
  saveButtonDisabled: {
    backgroundColor: colors.borderLight
  },
  saveText: {
    fontSize: fontSize.md,
    fontWeight: '600',
    color: colors.white
  },
  saveTextDisabled: {
    color: colors.textMuted
  }
})

export default Save
