import React from 'react'
import { View, StyleSheet } from 'react-native'
import { startOfWeek, addDays, getYear, getMonth, getDate, getDay } from 'date-fns'
import HabitDayLog from './habitDayLog'
import { spacing } from '../utils/theme'

interface Props {
  // The reference date for this week (any date within the week)
  weekDate: Date
  // Full achievements array
  achievements: Array<{
    year: number
    month: number
    day: number
    dayOfWeek: number
    achievement: boolean
  }>
  habitItemId: string
  // Optional: If provided, changes are local-only (not saved to Firebase immediately)
  onLocalToggle?: (year: number, month: number, day: number, dayOfWeek: number, newState: 'achieved' | 'notAchieved' | 'none') => void
}

const HabitWeekLog = (props: Props): React.ReactElement => {
  const { weekDate, achievements, habitItemId, onLocalToggle } = props

  // Get the start of the week (Sunday)
  const weekStart = startOfWeek(weekDate, { weekStartsOn: 0 })

  // Create a map of achievements by date string for quick lookup
  const achievementMap = new Map<string, { achievement: typeof achievements[0]; index: number }>()
  achievements.forEach((ach, index) => {
    const dateKey = `${ach.year}-${ach.month}-${ach.day}`
    achievementMap.set(dateKey, { achievement: ach, index })
  })

  // Generate all 7 days of the week
  const weekDays = []
  for (let i = 0; i < 7; i++) {
    const date = addDays(weekStart, i)
    const year = getYear(date)
    const month = getMonth(date) + 1 // getMonth is 0-indexed
    const day = getDate(date)
    const dayOfWeek = getDay(date)

    const dateKey = `${year}-${month}-${day}`
    const found = achievementMap.get(dateKey)

    weekDays.push({
      year,
      month,
      day,
      dayOfWeek,
      dailyAchievement: found?.achievement,
      achievementIndex: found?.index ?? -1
    })
  }

  return (
    <View style={styles.habitWeekLog}>
      {weekDays.map((dayInfo, index) => (
        <HabitDayLog
          key={index}
          year={dayInfo.year}
          month={dayInfo.month}
          day={dayInfo.day}
          dayOfWeek={dayInfo.dayOfWeek}
          dailyAchievement={dayInfo.dailyAchievement}
          accessableIndexOfAchievement={dayInfo.achievementIndex}
          achievements={achievements}
          habitItemId={habitItemId}
          onLocalToggle={onLocalToggle}
        />
      ))}
    </View>
  )
}

const styles = StyleSheet.create({
  habitWeekLog: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: spacing.xs
  }
})

export default HabitWeekLog
