import React, { useEffect, useState } from 'react'
import { Text, TextInput, View, StyleSheet, Alert, KeyboardAvoidingView, Platform, ScrollView } from 'react-native'
import { router, useNavigation } from 'expo-router'
import firebase from 'firebase/compat/app'
import { Ionicons } from '@expo/vector-icons'
import { useTranslation } from 'react-i18next'
import Save from '../../components/Save'
import { db, auth } from '../../utils/config'
import { colors, spacing, borderRadius, fontSize, shadow } from '../../utils/theme'

const MAX_MISSION_LENGTH = 16
const MAX_DETAIL_LENGTH = 70

const AddHabit = (): React.ReactElement => {
  const { t } = useTranslation()
  const [habitMission, setHabitMission] = useState('')
  const [habitMissionDetail, setHabitMissionDetail] = useState('')
  const headerNavigation = useNavigation()

  const handleSave = (mission: string, detail: string): void => {
    if (auth.currentUser === null) { return }

    const refToUserHabits = db.collection(`users/${auth.currentUser.uid}/habits`)

    const date: Date = new Date()
    const year: number = date.getFullYear()
    const month: number = date.getMonth() + 1
    const day: number = date.getDate()
    const dayOfWeek: number = date.getDay()

    refToUserHabits.add({
      habitMission: mission,
      habitMissionDetail: detail,
      achievements: [
        {
          year,
          month,
          day,
          dayOfWeek,
          achievement: false
        }
      ],
      updatedAt: firebase.firestore.Timestamp.fromDate(new Date())
    })
      .then(() => {
        router.back()
      })
      .catch((error) => {
        Alert.alert(t('screens.addHabit.addFailed'))
        console.log(error)
      })
  }

  useEffect(() => {
    headerNavigation.setOptions({
      headerRight: () => { return <Save onSave={() => { handleSave(habitMission, habitMissionDetail) }}/> }
    })
  }, [habitMission, habitMissionDetail])

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {/* Header Section */}
        <View style={styles.headerSection}>
          <Text style={styles.headerTitle}>{t('screens.addHabit.headerTitle')}</Text>
          <Text style={styles.headerSubtitle}>{t('screens.addHabit.headerSubtitle')}</Text>
        </View>

        {/* Mission Input Section */}
        <View style={styles.card}>
          <View style={styles.inputSection}>
            <View style={styles.labelContainer}>
              <Ionicons name="flag" size={20} color={colors.primary} />
              <Text style={styles.label}>{t('screens.addHabit.missionLabel')}</Text>
            </View>
            <TextInput
              onChangeText={(mission) => { setHabitMission(mission) }}
              value={habitMission}
              placeholder={t('screens.addHabit.missionPlaceholder')}
              placeholderTextColor={colors.textMuted}
              maxLength={MAX_MISSION_LENGTH}
              style={styles.textInput}
            />
          </View>

          <View style={styles.divider} />

          <View style={styles.inputSection}>
            <View style={styles.labelContainer}>
              <Ionicons name="document-text" size={20} color={colors.primary} />
              <Text style={styles.label}>{t('screens.addHabit.detailLabel')}</Text>
              <Text style={styles.charCounter}>{habitMissionDetail.length}/{MAX_DETAIL_LENGTH}</Text>
            </View>
            <TextInput
              onChangeText={(missionDetail) => { setHabitMissionDetail(missionDetail) }}
              value={habitMissionDetail}
              placeholder={t('screens.addHabit.detailPlaceholder')}
              placeholderTextColor={colors.textMuted}
              maxLength={MAX_DETAIL_LENGTH}
              multiline={true}
              numberOfLines={3}
              style={[styles.textInput, styles.textArea]}
            />
          </View>
        </View>

        {/* Tips Section */}
        <View style={styles.tipsSection}>
          <View style={styles.tipItem}>
            <Ionicons name="bulb-outline" size={18} color={colors.warning} />
            <Text style={styles.tipText}>{t('screens.addHabit.tip1')}</Text>
          </View>
          <View style={styles.tipItem}>
            <Ionicons name="time-outline" size={18} color={colors.secondary} />
            <Text style={styles.tipText}>{t('screens.addHabit.tip2')}</Text>
          </View>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background
  },
  scrollContent: {
    paddingHorizontal: spacing.lg,
    paddingBottom: spacing.xxl
  },
  headerSection: {
    alignItems: 'center',
    paddingTop: spacing.lg,
    paddingBottom: spacing.xl
  },
  iconContainer: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: colors.primaryLight + '20',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: spacing.md
  },
  headerTitle: {
    fontSize: fontSize.xxl,
    fontWeight: '700',
    color: colors.textPrimary,
    marginBottom: spacing.xs
  },
  headerSubtitle: {
    fontSize: fontSize.md,
    color: colors.textSecondary
  },
  card: {
    backgroundColor: colors.card,
    borderRadius: borderRadius.lg,
    padding: spacing.lg,
    ...shadow.md
  },
  inputSection: {
    marginBottom: spacing.sm
  },
  labelContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.sm
  },
  label: {
    fontSize: fontSize.md,
    fontWeight: '600',
    color: colors.textPrimary,
    marginLeft: spacing.sm,
    flex: 1
  },
  charCounter: {
    fontSize: fontSize.sm,
    color: colors.textMuted
  },
  textInput: {
    backgroundColor: colors.backgroundSecondary,
    borderRadius: borderRadius.md,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.md,
    fontSize: fontSize.md,
    color: colors.textPrimary
  },
  textArea: {
    height: 100,
    textAlignVertical: 'top'
  },
  divider: {
    height: 1,
    backgroundColor: colors.border,
    marginVertical: spacing.lg
  },
  tipsSection: {
    marginTop: spacing.xl,
    paddingHorizontal: spacing.sm
  },
  tipItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.sm
  },
  tipText: {
    fontSize: fontSize.sm,
    color: colors.textSecondary,
    marginLeft: spacing.sm
  }
})

export default AddHabit
