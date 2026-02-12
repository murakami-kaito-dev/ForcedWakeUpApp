import React from 'react'
import { useFonts } from 'expo-font'
import { createIconSetFromIcoMoon } from '@expo/vector-icons'
import fontData from '../assets/fonts/habitIcon.ttf'
import fontSelection from '../assets/fonts/selection.json'

interface Props {
  iconName: string
  iconColor: string
}

const CustomIcon = createIconSetFromIcoMoon(
  fontSelection,
  'IcoMoon',
  'habitIcon.ttf'
)

const Icon = (props: Props): React.ReactElement | null => {
  const { iconName, iconColor } = props
  const [fontLoaded] = useFonts({
    IcoMoon: fontData
  })

  // 画像を読み込めなかった場合, nullをreturn
  if (!fontLoaded) {
    return null
  }

  return (
    <CustomIcon
      name={iconName}
      size={48}
      color={iconColor}
    />
  )
}

export default Icon
