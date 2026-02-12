import React, { useEffect } from 'react'
import { View, Button } from 'react-native'
import * as Notifications from 'expo-notifications'
import { useTranslation } from 'react-i18next'

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: false,
    shouldShowBanner: true,
    shouldShowList: true
  })
})

const requestPermissionsAsync = async (): Promise<void> => {
  const { granted } = await Notifications.getPermissionsAsync()
  if (granted) { return }

  await Notifications.requestPermissionsAsync()
}

const App = (): React.ReactElement => {
  const { t } = useTranslation()

  const weekdayScheduleNotificationAsync = async (select: boolean): Promise<void> => {
    if (select) {
      await Notifications.scheduleNotificationAsync({
        content: {
          title: t('screens.app.testNotificationTitle'),
          body: 'test5000',
          sound: true
        },
        trigger: {
          type: Notifications.SchedulableTriggerInputTypes.WEEKLY,
          hour: 18,
          minute: 55,
          weekday: 4
        }
      })
    }

    // 通知のキャンセル処理
    // Notifications.cancelAllScheduledNotificationsAsync()
  }

  useEffect(() => {
    requestPermissionsAsync()
      .then(() => {})
      .catch(() => {})
  })

  return (
    <View>
      <Button
        title={t('screens.app.testNotificationButton')}
        onPress={ () => { weekdayScheduleNotificationAsync(true) } }
      />
    </View>
  )
}

export default App
