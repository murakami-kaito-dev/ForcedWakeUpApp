import React, { useState, useEffect, useCallback } from 'react'
import { Text, View, TextInput, StyleSheet, Alert, TouchableOpacity, ScrollView, useWindowDimensions } from 'react-native'
import { Link, router, useNavigation, useLocalSearchParams } from 'expo-router'
import * as Notifications from 'expo-notifications'
import firebase from 'firebase/compat/app'
import { Ionicons } from '@expo/vector-icons'
import { subWeeks, startOfWeek, endOfWeek, format } from 'date-fns'
import { useTranslation } from 'react-i18next'
import HabitWeekLog from '../../components/habitWeekLog'
import Save from '../../components/Save'
import { db, auth } from '../../utils/config'
import { type HabitItemAlarm } from '../../types/habit'
import { colors, spacing, borderRadius, fontSize, shadow } from '../../utils/theme'

const MAX_DETAIL_LENGTH = 70

// Achievement type definition
type Achievement = {
  year: number
  month: number
  day: number
  dayOfWeek: number
  achievement: boolean
}

const EditHabit = (): React.ReactElement => {
  const { t } = useTranslation()
  const { width } = useWindowDimensions()
  // Calculate cell width to match habitDayLog cells
  const cardPadding = 32
  const cellMargin = 4
  const availableWidth = Math.min(width - 32, 380) - cardPadding
  const cellWidth = Math.floor((availableWidth - (cellMargin * 6)) / 7)

  const [alarmItems, setAlarmItems] = useState<HabitItemAlarm[]>([])
  const [habitMission, setHabitMission] = useState('')
  const [habitMissionDetail, setHabitMissionDetail] = useState('')
  // achievements from Firebase (original, for comparison)
  const [achievements, setAchievements] = useState<Achievement[]>([])
  // localAchievements for editing (not saved until user presses Save)
  const [localAchievements, setLocalAchievements] = useState<Achievement[]>([])
  // Track initial values for change detection
  const [initialHabitMission, setInitialHabitMission] = useState('')
  const [initialHabitMissionDetail, setInitialHabitMissionDetail] = useState('')
  // Calendar navigation offset (0 = current 4 weeks, 1 = previous 4 weeks, etc.)
  const [calendarOffset, setCalendarOffset] = useState(0)
  const habitItemId = String(useLocalSearchParams().habitItemId)
  const headerNavigation = useNavigation()

  const handleDeleteAlarm = async (alarmId: string): Promise<void> => {
    if (auth.currentUser === null) { return }

    const refToUsersHabitsAlarms = db.doc(`users/${auth.currentUser.uid}/habits/${habitItemId}/alarms/${alarmId}`)
    const refToUsersHabitsAlarmsAlarmId = await refToUsersHabitsAlarms.get()

    Alert.alert(t('screens.editHabit.deleteTitle'), t('screens.editHabit.deleteMessage'), [
      {
        text: t('common.cancel')
      },
      {
        text: t('common.delete'),
        style: 'destructive',
        onPress: () => {
          refToUsersHabitsAlarms.delete()
            .catch(() => { Alert.alert(t('screens.editHabit.deleteFailed')) })

          refToUsersHabitsAlarmsAlarmId.data()?.alarmIdentifier.forEach((preAlarmIdentifier: null | string) => {
            if (preAlarmIdentifier === null) {
              // Do Nothing
            } else {
              Notifications.cancelScheduledNotificationAsync(preAlarmIdentifier)
                .then(() => { console.log('.then実行') })
                .catch((error) => { console.log('error:', error) })
            }
          })
        }
      }
    ])
  }

  // Helper function to compare achievements arrays
  const achievementsEqual = (a: Achievement[], b: Achievement[]): boolean => {
    if (a.length !== b.length) return false
    return a.every((item, index) => {
      const other = b[index]
      return item.year === other.year &&
             item.month === other.month &&
             item.day === other.day &&
             item.achievement === other.achievement
    })
  }

  // Check if there are unsaved changes (including achievements)
  const hasChanges = habitMission !== initialHabitMission ||
                     habitMissionDetail !== initialHabitMissionDetail ||
                     !achievementsEqual(localAchievements, achievements)

  // Handle local achievement toggle with 3 states: achieved / notAchieved / none
  const handleLocalToggle = useCallback((year: number, month: number, day: number, dayOfWeek: number, newState: 'achieved' | 'notAchieved' | 'none') => {
    setLocalAchievements(prev => {
      let updated = [...prev]
      const existingIndex = updated.findIndex(
        a => a.year === year && a.month === month && a.day === day
      )

      if (newState === 'none') {
        // Remove the record
        if (existingIndex >= 0) {
          updated = updated.filter((_, i) => i !== existingIndex)
        }
      } else if (existingIndex >= 0) {
        // Update existing record
        updated[existingIndex] = { ...updated[existingIndex], achievement: newState === 'achieved' }
      } else {
        // Create new record
        updated.push({ year, month, day, dayOfWeek, achievement: newState === 'achieved' })
        // Sort by date (oldest first)
        updated.sort((a, b) => {
          const dateA = new Date(a.year, a.month - 1, a.day)
          const dateB = new Date(b.year, b.month - 1, b.day)
          return dateA.getTime() - dateB.getTime()
        })
      }

      return updated
    })
  }, [])

  // Handle save (including achievements)
  const handleSave = (): void => {
    if (auth.currentUser === null) { return }
    const refToUsersHabits = db.doc(`users/${auth.currentUser.uid}/habits/${habitItemId}`)
    refToUsersHabits.set(
      {
        habitMission,
        habitMissionDetail,
        achievements: localAchievements,
        updatedAt: firebase.firestore.Timestamp.fromDate(new Date())
      },
      { merge: true }
    )
      .then(() => {
        router.back()
      })
      .catch(() => {
        Alert.alert(t('screens.editHabit.updateFailed'))
      })
  }

  // Generate week dates based on calendar offset
  // offset 0 = current 4 weeks (including today)
  // offset 1 = previous 4 weeks, etc.
  const today = new Date()
  const baseOffset = calendarOffset * 4
  const weekDates = [
    subWeeks(today, baseOffset + 3),
    subWeeks(today, baseOffset + 2),
    subWeeks(today, baseOffset + 1),
    subWeeks(today, baseOffset)
  ]

  // Calculate date range for display (top-left to bottom-right)
  const periodStartDate = startOfWeek(weekDates[0], { weekStartsOn: 0 }) // Sunday of first week
  const periodEndDate = endOfWeek(weekDates[3], { weekStartsOn: 0 }) // Saturday of last week
  const periodLabel = `${format(periodStartDate, 'yyyy/MM/dd')}〜${format(periodEndDate, 'yyyy/MM/dd')}`

  // Navigation handlers
  const handlePrevious = (): void => {
    setCalendarOffset(prev => prev + 1)
  }

  const handleNext = (): void => {
    if (calendarOffset > 0) {
      setCalendarOffset(prev => prev - 1)
    }
  }

  useEffect(() => {
    headerNavigation.setOptions({
      headerRight: () => {
        return (
          <Save
            onSave={handleSave}
            disabled={!hasChanges}
          />
        )
      }
    })
  }, [habitMission, habitMissionDetail, localAchievements, hasChanges])

  useEffect(() => {
    if (auth.currentUser === null) { return }

    const refToUsersHabits = db.doc(`users/${auth.currentUser.uid}/habits/${habitItemId}`)
    let isFirstLoad = true

    // Use onSnapshot for real-time updates
    const unsubscribe = refToUsersHabits.onSnapshot((docSnap) => {
      if (docSnap.exists) {
        const data = docSnap.data()
        const mission = data?.habitMission || ''
        const missionDetail = data?.habitMissionDetail || ''
        const remoteAchievements = data?.achievements || []

        // Only set initial/local values on first load
        if (isFirstLoad) {
          setInitialHabitMission(mission)
          setInitialHabitMissionDetail(missionDetail)
          setHabitMission(mission)
          setHabitMissionDetail(missionDetail)
          // Set localAchievements as a copy of remote achievements
          setLocalAchievements([...remoteAchievements])
          isFirstLoad = false
        }

        // Always update the original achievements for comparison
        setAchievements(remoteAchievements)
      }
    })

    return unsubscribe
  }, [habitItemId])

  useEffect(() => {
    if (auth.currentUser === null) { return }

    const refToUsersHabitsAlarmsItems = db.collection(`users/${auth.currentUser.uid}/habits/${habitItemId}/alarms`)
    const queryAlarmItems = refToUsersHabitsAlarmsItems.orderBy('alarmTime.hours', 'desc')
    const unsubscribeEditHabitScreen = queryAlarmItems.onSnapshot((snapshot) => {
      const remoteAlarmItems: HabitItemAlarm[] = []

      snapshot.forEach((docAlarmItems) => {
        const { alarmTime, repeatDayOfWeek, updatedAt } = docAlarmItems.data()
        remoteAlarmItems.push({
          alarmId: docAlarmItems.id,
          alarmTime: { hours: alarmTime.hours, minutes: alarmTime.minutes, seconds: alarmTime.seconds },
          repeatDayOfWeek,
          updatedAt
        })
      })
      setAlarmItems(remoteAlarmItems)
    })
    return unsubscribeEditHabitScreen
  }, [habitItemId])

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.scrollContent}>
      {/* Header with Title */}
      <View style={styles.headerCard}>
        <View style={styles.sectionHeader}>
          <Ionicons name="flag" size={20} color={colors.primary} />
          <Text style={styles.sectionTitle}>{t('screens.editHabit.habitLabel')}</Text>
        </View>
        <View style={styles.habitTitleInputContainer}>
          <TextInput
            style={styles.habitTitleInput}
            editable={true}
            value={habitMission}
            maxLength={14}
            placeholder={t('screens.editHabit.habitPlaceholder')}
            placeholderTextColor={colors.textMuted}
            onChangeText={(text) => { setHabitMission(text) }}
          />
          <Ionicons name="pencil" size={18} color={colors.textMuted} style={styles.editIcon} />
        </View>
      </View>

      {/* Week Log Section */}
      <View style={styles.sectionCard}>
        <View style={styles.sectionHeader}>
          <Ionicons name="calendar" size={20} color={colors.primary} />
          <Text style={styles.sectionTitle}>{t('screens.editHabit.achievementLabel')}</Text>
        </View>

        {/* Calendar Navigation */}
        <View style={styles.calendarNavigation}>
          <TouchableOpacity
            style={styles.navButton}
            onPress={handlePrevious}
          >
            <Ionicons name="chevron-back" size={24} color={colors.primary} />
          </TouchableOpacity>

          <Text style={styles.navPeriodText}>
            {periodLabel}
          </Text>

          <TouchableOpacity
            style={[styles.navButton, calendarOffset === 0 && styles.navButtonDisabled]}
            onPress={handleNext}
            disabled={calendarOffset === 0}
          >
            <Ionicons name="chevron-forward" size={24} color={calendarOffset === 0 ? colors.textMuted : colors.primary} />
          </TouchableOpacity>
        </View>

        {/* Day of week header */}
        <View style={styles.dayOfWeekHeader}>
          {(t('weekdays.short', { returnObjects: true }) as string[]).map((dayLabel, index) => (
            <View key={dayLabel} style={[styles.dayOfWeekLabelContainer, { width: cellWidth }]}>
              <Text
                style={[
                  styles.dayOfWeekLabel,
                  index === 0 && styles.sundayLabel,
                  index === 6 && styles.saturdayLabel
                ]}
              >
                {dayLabel}
              </Text>
            </View>
          ))}
        </View>

        <View style={styles.weekLogContainer}>
          {weekDates.map((weekDate, index) => (
            <HabitWeekLog
              key={`${calendarOffset}-${index}`}
              weekDate={weekDate}
              achievements={localAchievements}
              habitItemId={habitItemId}
              onLocalToggle={handleLocalToggle}
            />
          ))}
        </View>
      </View>

      {/* Detail Section */}
      <View style={styles.sectionCard}>
        <View style={styles.sectionHeader}>
          <Ionicons name="document-text" size={20} color={colors.primary} />
          <Text style={styles.sectionTitle}>{t('screens.editHabit.detailLabel')}</Text>
          <Text style={styles.charCounter}>
            {habitMissionDetail.length}/{MAX_DETAIL_LENGTH}
          </Text>
        </View>
        <TextInput
          editable={true}
          placeholder={t('screens.editHabit.detailPlaceholder')}
          placeholderTextColor={colors.textMuted}
          multiline={true}
          numberOfLines={4}
          maxLength={MAX_DETAIL_LENGTH}
          style={styles.detailInput}
          value={habitMissionDetail}
          onChangeText={(text) => { setHabitMissionDetail(text) }}
        />
      </View>

      {/* Alarm Section */}
      <View style={styles.sectionCard}>
        <View style={styles.sectionHeader}>
          <Ionicons name="notifications" size={20} color={colors.primary} />
          <Text style={styles.sectionTitle}>{t('screens.editHabit.notificationLabel')}</Text>
          <Link href={{ pathname: './addAlarm', params: { habitItemId, habitMission, habitMissionDetail } }} asChild>
            <TouchableOpacity style={styles.addAlarmButton}>
              <Ionicons name="add" size={24} color={colors.primary} />
            </TouchableOpacity>
          </Link>
        </View>

        {alarmItems.length === 0 ? (
          <View style={styles.emptyAlarm}>
            <Ionicons name="notifications-off-outline" size={32} color={colors.textMuted} />
            <Text style={styles.emptyAlarmText}>{t('screens.editHabit.noNotification')}</Text>
          </View>
        ) : (
          alarmItems.map((alarmItem) => {
            const everydayAlarmExists = alarmItem.repeatDayOfWeek.every(day => day)
            const hasAlarms = alarmItem.repeatDayOfWeek.some(day => day)
            const weekdaysShort = t('weekdays.short', { returnObjects: true }) as string[]

            return (
              <Link
                key={alarmItem.alarmId}
                href={{ pathname: './editAlarm', params: { habitItemId, habitMission, habitMissionDetail, alarmId: alarmItem.alarmId } }}
                asChild
              >
                <TouchableOpacity style={styles.alarmItem}>
                  <View style={styles.alarmContent}>
                    <Text style={styles.alarmTime}>
                      {alarmItem.alarmTime.hours}:{String(alarmItem.alarmTime.minutes).padStart(2, '0')}
                    </Text>
                    {everydayAlarmExists ? (
                      <Text style={styles.repeatWeek}>{t('screens.editHabit.everyday')}</Text>
                    ) : hasAlarms ? (
                      <Text style={styles.repeatWeek}>
                        {alarmItem.repeatDayOfWeek[0] && `${weekdaysShort[0]} `}
                        {alarmItem.repeatDayOfWeek[1] && `${weekdaysShort[1]} `}
                        {alarmItem.repeatDayOfWeek[2] && `${weekdaysShort[2]} `}
                        {alarmItem.repeatDayOfWeek[3] && `${weekdaysShort[3]} `}
                        {alarmItem.repeatDayOfWeek[4] && `${weekdaysShort[4]} `}
                        {alarmItem.repeatDayOfWeek[5] && `${weekdaysShort[5]} `}
                        {alarmItem.repeatDayOfWeek[6] && weekdaysShort[6]}
                      </Text>
                    ) : (
                      <Text style={styles.repeatWeekWarning}>{t('screens.editHabit.setWeekday')}</Text>
                    )}
                  </View>
                  <TouchableOpacity
                    style={styles.deleteAlarmButton}
                    onPress={() => {
                      handleDeleteAlarm(alarmItem.alarmId)
                        .catch((error) => { console.log(error) })
                    }}
                  >
                    <Ionicons name="trash-outline" size={20} color={colors.textMuted} />
                  </TouchableOpacity>
                </TouchableOpacity>
              </Link>
            )
          })
        )}
      </View>
    </ScrollView>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background
  },
  scrollContent: {
    paddingHorizontal: spacing.md,
    paddingTop: spacing.md,
    paddingBottom: spacing.xxl
  },
  headerCard: {
    backgroundColor: colors.card,
    borderRadius: borderRadius.lg,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadow.md
  },
  habitTitleInputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.backgroundSecondary,
    borderRadius: borderRadius.md,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm
  },
  habitTitleInput: {
    fontSize: fontSize.lg,
    fontWeight: '600',
    color: colors.textPrimary,
    flex: 1
  },
  editIcon: {
    marginLeft: spacing.sm
  },
  sectionCard: {
    backgroundColor: colors.card,
    borderRadius: borderRadius.lg,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadow.md
  },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.md
  },
  sectionTitle: {
    fontSize: fontSize.lg,
    fontWeight: '600',
    color: colors.textPrimary,
    marginLeft: spacing.sm,
    flex: 1
  },
  charCounter: {
    fontSize: fontSize.sm,
    color: colors.textMuted
  },
  calendarNavigation: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: spacing.md,
    paddingHorizontal: spacing.sm
  },
  navButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: colors.backgroundSecondary,
    justifyContent: 'center',
    alignItems: 'center'
  },
  navButtonDisabled: {
    opacity: 0.5
  },
  navPeriodText: {
    fontSize: fontSize.sm,
    fontWeight: '600',
    color: colors.textPrimary,
    textAlign: 'center'
  },
  dayOfWeekHeader: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginBottom: spacing.xs
  },
  dayOfWeekLabelContainer: {
    alignItems: 'center',
    marginHorizontal: 2
  },
  dayOfWeekLabel: {
    fontSize: fontSize.xs,
    fontWeight: '600',
    color: colors.textSecondary
  },
  sundayLabel: {
    color: colors.sunday
  },
  saturdayLabel: {
    color: colors.saturday
  },
  weekLogContainer: {
    gap: spacing.xs
  },
  detailInput: {
    backgroundColor: colors.backgroundSecondary,
    borderRadius: borderRadius.md,
    padding: spacing.md,
    fontSize: fontSize.md,
    color: colors.textPrimary,
    minHeight: 100,
    textAlignVertical: 'top'
  },
  addAlarmButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: colors.primaryLight + '20',
    justifyContent: 'center',
    alignItems: 'center'
  },
  emptyAlarm: {
    alignItems: 'center',
    paddingVertical: spacing.xl
  },
  emptyAlarmText: {
    fontSize: fontSize.sm,
    color: colors.textMuted,
    marginTop: spacing.sm
  },
  alarmItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.backgroundSecondary,
    borderRadius: borderRadius.md,
    padding: spacing.md,
    marginBottom: spacing.sm
  },
  alarmContent: {
    flex: 1
  },
  alarmTime: {
    fontSize: fontSize.xxxl,
    fontWeight: '300',
    color: colors.textPrimary
  },
  repeatWeek: {
    fontSize: fontSize.sm,
    color: colors.textSecondary,
    marginTop: spacing.xs
  },
  repeatWeekWarning: {
    fontSize: fontSize.sm,
    color: colors.warning,
    marginTop: spacing.xs
  },
  deleteAlarmButton: {
    padding: spacing.sm
  }
})

export default EditHabit
