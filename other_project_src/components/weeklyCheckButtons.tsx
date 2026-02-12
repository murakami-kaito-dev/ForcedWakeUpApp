import React from 'react'
import { View, StyleSheet } from 'react-native'
import { startOfWeek, addDays, getYear, getMonth, getDate, getDay, isToday as checkIsToday, isFuture as checkIsFuture } from 'date-fns'
import DayCheckButton from './dayCheckButton'
import { auth } from '../utils/config'
import { type Habit } from '../types/habit'
import { spacing } from '../utils/theme'

interface Props {
  habitItem: Habit
  habitItemId: string
  achievements: Array<{
    year: number
    month: number
    day: number
    dayOfWeek: number
    achievement: boolean
  }>
}

const WeeklyCheckButtons = (props: Props): React.ReactElement => {
  const { habitItem, habitItemId, achievements } = props
  const dayCheckButtonKey: string = habitItem.habitMission

  if (auth.currentUser === null) {
    console.log('ユーザーログインがされていません')
    return <></>
  }

  // Get the current week (Sunday to Saturday)
  const today = new Date()
  const weekStart = startOfWeek(today, { weekStartsOn: 0 })

  // Handle empty or undefined achievements - still show interactive week
  const safeAchievements = achievements || []

  // Create a map of achievements by date for quick lookup
  const achievementMap = new Map<string, { achievement: typeof safeAchievements[0]; index: number }>()
  safeAchievements.forEach((ach, index) => {
    const dateKey = `${ach.year}-${ach.month}-${ach.day}`
    achievementMap.set(dateKey, { achievement: ach, index })
  })

  // Generate all 7 days of the current week
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
      isToday: checkIsToday(date),
      isFuture: checkIsFuture(date),
      achievementData: found?.achievement,
      achievementIndex: found?.index ?? -1
    })
  }

  return (
    <View style={styles.weeklyCheckButtons}>
      {weekDays.map((dayInfo, index) => (
        <DayCheckButton
          key={dayCheckButtonKey + index}
          habitItemId={habitItemId}
          achievementsIndex={dayInfo.achievementIndex >= 0 ? dayInfo.achievementIndex : undefined}
          achievementLog={dayInfo.achievementData?.achievement}
          achievements={safeAchievements}
          dayOfWeek={dayInfo.dayOfWeek}
          isToday={dayInfo.isToday}
          isFuture={dayInfo.isFuture}
          year={dayInfo.year}
          month={dayInfo.month}
          day={dayInfo.day}
        />
      ))}
    </View>
  )
}

const styles = StyleSheet.create({
  weeklyCheckButtons: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: spacing.xs
  }
})

export default WeeklyCheckButtons
