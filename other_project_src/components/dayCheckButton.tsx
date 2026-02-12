import React, { useState, useEffect } from 'react'
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native'
import { useTranslation } from 'react-i18next'
import { db, auth } from '../utils/config'
import { Ionicons } from '@expo/vector-icons'
import { colors, spacing, fontSize } from '../utils/theme'

// Achievement states: 'achieved' | 'notAchieved' | 'none'
type AchievementState = 'achieved' | 'notAchieved' | 'none'

interface Props {
  habitItemId?: string
  achievementsIndex?: number
  achievementLog?: boolean
  achievements?: Array<{
    year: number
    month: number
    day: number
    dayOfWeek: number
    achievement: boolean
  }>
  dayOfWeek?: number
  isToday?: boolean
  isFuture?: boolean
  // Date info for deletion
  year?: number
  month?: number
  day?: number
}

const DayCheckButton = (props: Props): React.ReactElement => {
  const { t } = useTranslation()
  const { habitItemId, achievementsIndex, achievementLog, achievements, dayOfWeek, isToday, isFuture, year, month, day } = props
  const dayLabels = t('weekdays.short', { returnObjects: true }) as string[]

  // Determine initial state
  const getInitialState = (): AchievementState => {
    if (achievementLog === undefined) return 'none'
    return achievementLog ? 'achieved' : 'notAchieved'
  }

  const [currentState, setCurrentState] = useState<AchievementState>(getInitialState())

  // Sync with props
  useEffect(() => {
    setCurrentState(getInitialState())
  }, [achievementLog])

  // Get next state in the cycle: none → achieved → notAchieved → none
  const getNextState = (current: AchievementState): AchievementState => {
    switch (current) {
      case 'none': return 'achieved'
      case 'achieved': return 'notAchieved'
      case 'notAchieved': return 'none'
    }
  }

  const handlePress = async (): Promise<void> => {
    if (auth.currentUser === null) { return }
    if (habitItemId === undefined || achievements === undefined) { return }

    const nextState = getNextState(currentState)
    setCurrentState(nextState)

    const refToUserHabitsItemId = db.doc(`users/${auth.currentUser.uid}/habits/${habitItemId}`)

    try {
      // Get current achievements from Firestore
      const docSnap = await refToUserHabitsItemId.get()
      if (!docSnap.exists) return

      let updatedAchievements = [...(docSnap.data()?.achievements || [])]

      if (nextState === 'none') {
        // Remove the record
        if (achievementsIndex !== undefined && achievementsIndex >= 0) {
          updatedAchievements = updatedAchievements.filter((_, i) => i !== achievementsIndex)
        } else if (year !== undefined && month !== undefined && day !== undefined) {
          // Find and remove by date
          updatedAchievements = updatedAchievements.filter(
            a => !(a.year === year && a.month === month && a.day === day)
          )
        }
      } else if (achievementsIndex !== undefined && achievementsIndex >= 0) {
        // Update existing record
        updatedAchievements[achievementsIndex].achievement = nextState === 'achieved'
      } else if (year !== undefined && month !== undefined && day !== undefined && dayOfWeek !== undefined) {
        // Create new record
        updatedAchievements.push({
          year,
          month,
          day,
          dayOfWeek,
          achievement: nextState === 'achieved'
        })
        // Sort by date
        updatedAchievements.sort((a, b) => {
          const dateA = new Date(a.year, a.month - 1, a.day)
          const dateB = new Date(b.year, b.month - 1, b.day)
          return dateA.getTime() - dateB.getTime()
        })
      }

      await refToUserHabitsItemId.set(
        { achievements: updatedAchievements },
        { merge: true }
      )
    } catch (error) {
      console.log('Error updating achievement:', error)
      // Revert state on error
      setCurrentState(currentState)
    }
  }

  // Render based on current state
  const renderContent = (): React.ReactElement => {
    switch (currentState) {
      case 'achieved':
        return <Ionicons name='checkmark' size={20} color={colors.white} />
      case 'notAchieved':
        return <Ionicons name='close' size={20} color={colors.white} />
      case 'none':
        return <View style={styles.emptyDot} />
    }
  }

  const getButtonStyle = () => {
    switch (currentState) {
      case 'achieved':
        return styles.achievedStatus
      case 'notAchieved':
        return styles.notAchievedStatus
      case 'none':
        return styles.noLogStatus
    }
  }

  // Check if this is an interactive button (has required data for Firebase operations)
  // Future dates should not be interactive
  const isInteractive = habitItemId !== undefined && achievements !== undefined && isFuture !== true

  return (
    <View style={styles.dayContainer}>
      {dayOfWeek !== undefined && (
        <Text style={[
          styles.dayLabel,
          dayOfWeek === 0 && styles.sundayLabel,
          dayOfWeek === 6 && styles.saturdayLabel
        ]}>
          {dayLabels[dayOfWeek]}
        </Text>
      )}
      {isInteractive
        ? (
        <TouchableOpacity
          style={[
            styles.statusButton,
            getButtonStyle(),
            isToday === true && styles.todayBorder
          ]}
          onPress={handlePress}
        >
          {renderContent()}
        </TouchableOpacity>
          )
        : (
        <View style={[styles.statusButton, styles.noLogStatus]}>
          <View style={styles.emptyDot} />
        </View>
          )}
    </View>
  )
}

const styles = StyleSheet.create({
  dayContainer: {
    alignItems: 'center',
    marginHorizontal: spacing.xs
  },
  dayLabel: {
    fontSize: fontSize.xs,
    fontWeight: '600',
    color: colors.textSecondary,
    marginBottom: spacing.xs
  },
  sundayLabel: {
    color: colors.sunday
  },
  saturdayLabel: {
    color: colors.saturday
  },
  statusButton: {
    height: 38,
    width: 38,
    borderRadius: 19,
    justifyContent: 'center',
    alignItems: 'center'
  },
  noLogStatus: {
    backgroundColor: colors.borderLight
  },
  emptyDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: colors.border
  },
  achievedStatus: {
    backgroundColor: colors.success
  },
  notAchievedStatus: {
    backgroundColor: colors.error
  },
  todayBorder: {
    borderWidth: 3,
    borderColor: colors.primaryDark
  }
})

export default DayCheckButton
