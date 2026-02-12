import { type Habit } from '../types/habit'

/**
 * Previously filled in missing achievement records from the last recorded date to today.
 * Now this function does nothing - missing days are left as "no record" (無表示).
 * Kept for backwards compatibility in case it's called from other parts of the app.
 */
const subtractYearMonthDay = (habitItem: Habit, latestAccess: {
  year: number
  month: number
  day: number
  dayOfWeek: number
}): void => {
  // Do nothing - missing days should remain as "no record" (無表示)
  // instead of being marked as "not achieved" (✗)
}

export default subtractYearMonthDay
