import React, { useState, useEffect } from 'react'
import { View, Text, StyleSheet, TouchableOpacity, useWindowDimensions } from 'react-native'
import { Ionicons } from '@expo/vector-icons'
import { isToday as checkIsToday, isFuture } from 'date-fns'
import { db, auth } from '../utils/config'
import { colors, spacing, borderRadius } from '../utils/theme'

// Achievement states: 'achieved' | 'notAchieved' | 'none'
// - achieved: record exists with achievement: true
// - notAchieved: record exists with achievement: false
// - none: no record exists (will be deleted from Firebase)

interface Props {
  year: number
  month: number
  day: number
  dayOfWeek: number
  dailyAchievement?: {
    year: number
    month: number
    day: number
    dayOfWeek: number
    achievement: boolean
  }
  achievements: Array<{
    year: number
    month: number
    day: number
    dayOfWeek: number
    achievement: boolean
  }>
  accessableIndexOfAchievement: number
  habitItemId: string
  onLocalToggle?: (year: number, month: number, day: number, dayOfWeek: number, newState: 'achieved' | 'notAchieved' | 'none') => void
}

type AchievementState = 'achieved' | 'notAchieved' | 'none'

const HabitDayLog = (props: Props): React.ReactElement => {
  const { width } = useWindowDimensions()
  const cardPadding = 32
  const cellMargin = 4
  const availableWidth = Math.min(width - 32, 380) - cardPadding
  const cellWidth = Math.floor((availableWidth - (cellMargin * 6)) / 7)

  const { year, month, day, dayOfWeek, dailyAchievement, achievements, accessableIndexOfAchievement, habitItemId, onLocalToggle } = props

  // Determine the current state from props
  const getStateFromProps = (): AchievementState => {
    if (!dailyAchievement) return 'none'
    return dailyAchievement.achievement ? 'achieved' : 'notAchieved'
  }

  const [currentState, setCurrentState] = useState<AchievementState>(getStateFromProps())

  // Check if this date is today
  const date = new Date(year, month - 1, day)
  const isToday = checkIsToday(date)
  const isFutureDate = isFuture(date)

  // Sync state when props change
  useEffect(() => {
    setCurrentState(getStateFromProps())
  }, [dailyAchievement])

  // Get next state in the cycle: none → achieved → notAchieved → none
  const getNextState = (current: AchievementState): AchievementState => {
    switch (current) {
      case 'none': return 'achieved'
      case 'achieved': return 'notAchieved'
      case 'notAchieved': return 'none'
    }
  }

  const handleToggle = async (): Promise<void> => {
    // Don't allow toggling future dates
    if (isFutureDate) return

    const nextState = getNextState(currentState)

    // If onLocalToggle is provided, use local-only mode (for editHabit screen)
    if (onLocalToggle) {
      setCurrentState(nextState)
      onLocalToggle(year, month, day, dayOfWeek, nextState)
      return
    }

    // Otherwise, save directly to Firebase (for Home screen)
    if (auth.currentUser === null) { return }

    const refToUserHabitsItemId = db.doc(`users/${auth.currentUser.uid}/habits/${habitItemId}`)

    try {
      const docSnap = await refToUserHabitsItemId.get()
      if (!docSnap.exists) return

      let currentAchievements = [...(docSnap.data()?.achievements || [])]

      if (nextState === 'none') {
        // Remove the record
        currentAchievements = currentAchievements.filter(
          a => !(a.year === year && a.month === month && a.day === day)
        )
      } else if (accessableIndexOfAchievement >= 0) {
        // Update existing record
        currentAchievements[accessableIndexOfAchievement].achievement = nextState === 'achieved'
      } else {
        // Create new record
        currentAchievements.push({
          year,
          month,
          day,
          dayOfWeek,
          achievement: nextState === 'achieved'
        })
        // Sort by date
        currentAchievements.sort((a, b) => {
          const dateA = new Date(a.year, a.month - 1, a.day)
          const dateB = new Date(b.year, b.month - 1, b.day)
          return dateA.getTime() - dateB.getTime()
        })
      }

      setCurrentState(nextState)

      await refToUserHabitsItemId.set({
        achievements: currentAchievements
      }, { merge: true })
    } catch (error) {
      console.log('Error updating achievement:', error)
    }
  }

  return (
    <View style={[styles.habitDayLog, { width: cellWidth }, isToday && styles.todayBorder]}>
      <View style={[styles.day, isToday && styles.todayHeader]}>
        <Text style={[styles.dayText, isToday && styles.todayText]}>{month}/{day}</Text>
      </View>
      <TouchableOpacity
        style={[
          styles.log,
          currentState === 'none' && styles.noLog,
          currentState === 'achieved' && styles.logAchieved,
          currentState === 'notAchieved' && styles.logNotAchieved,
          isFutureDate && styles.futureDate
        ]}
        onPress={handleToggle}
        disabled={isFutureDate}
      >
        {currentState === 'none' ? (
          <View style={styles.emptyDot} />
        ) : currentState === 'achieved' ? (
          <Ionicons name='checkmark' size={16} color={colors.white} />
        ) : (
          <Ionicons name='close' size={16} color={colors.white} />
        )}
      </TouchableOpacity>
    </View>
  )
}

const styles = StyleSheet.create({
  habitDayLog: {
    backgroundColor: colors.card,
    borderRadius: borderRadius.sm,
    marginHorizontal: 2,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: colors.border
  },
  todayBorder: {
    borderWidth: 2,
    borderColor: colors.primaryDark
  },
  day: {
    backgroundColor: colors.backgroundSecondary,
    paddingVertical: 2,
    alignItems: 'center'
  },
  todayHeader: {
    backgroundColor: colors.primaryDark
  },
  dayText: {
    fontSize: 10,
    color: colors.textSecondary,
    fontWeight: '500'
  },
  todayText: {
    color: colors.white,
    fontWeight: '700'
  },
  log: {
    paddingVertical: spacing.sm,
    alignItems: 'center',
    justifyContent: 'center'
  },
  logAchieved: {
    backgroundColor: colors.success
  },
  logNotAchieved: {
    backgroundColor: colors.error
  },
  noLog: {
    backgroundColor: colors.borderLight
  },
  futureDate: {
    opacity: 0.4
  },
  emptyDot: {
    width: 16,
    height: 16,
    borderRadius: 8,
    backgroundColor: colors.border
  }
})

export default HabitDayLog
