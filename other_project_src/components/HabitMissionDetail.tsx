import React from 'react'
import { View, Text, StyleSheet, TextInput } from 'react-native'
import { useTranslation } from 'react-i18next'

const HabitMissionDetail = (): React.ReactElement => {
  const { t } = useTranslation()
  return (
    <View style={styles.habitMissionDetailSection}>
      <Text style={styles.habitMissionDetailDescription}>{t('components.habitMissionDetail.title')}</Text>
      <TextInput
        editable = { true }
        placeholder = {t('components.habitMissionDetail.placeholder')}
        multiline = { true }
        numberOfLines = { 4 }
        style = {styles.habitMissionDetail}
      />
    </View>
  )
}

const styles = StyleSheet.create({
  habitMissionDetailSection: {
    paddingLeft: 24,
    paddingRight: 24,
    marginBottom: 16
  },
  habitMissionDetailDescription: {
    fontSize: 24,
    lineHeight: 32
  },
  habitMissionDetail: {
    backgroundColor: '#ffffff',
    borderWidth: 1,
    borderRadius: 10,
    height: 136,
    width: 336,
    lineHeight: 24,
    fontSize: 24
  }
})

export default HabitMissionDetail
