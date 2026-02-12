import React, { useEffect, useRef, useState } from 'react'
import {
  View,
  StyleSheet,
  Animated,
  Dimensions,
  TouchableWithoutFeedback,
  Platform
} from 'react-native'
import { colors } from '../utils/theme'

const { width: SCREEN_WIDTH } = Dimensions.get('window')
const SIDEBAR_WIDTH = SCREEN_WIDTH * 0.75

interface Props {
  isOpen: boolean
  onClose: () => void
}

const Sidebar = ({ isOpen, onClose }: Props): React.ReactElement | null => {
  const slideAnim = useRef(new Animated.Value(-SIDEBAR_WIDTH)).current
  const overlayAnim = useRef(new Animated.Value(0)).current
  const [isVisible, setIsVisible] = useState(false)

  useEffect(() => {
    if (isOpen) {
      setIsVisible(true)
      Animated.parallel([
        Animated.spring(slideAnim, {
          toValue: 0,
          useNativeDriver: true,
          tension: 65,
          friction: 11
        }),
        Animated.timing(overlayAnim, {
          toValue: 1,
          duration: 300,
          useNativeDriver: true
        })
      ]).start()
    } else {
      Animated.parallel([
        Animated.timing(slideAnim, {
          toValue: -SIDEBAR_WIDTH,
          duration: 250,
          useNativeDriver: true
        }),
        Animated.timing(overlayAnim, {
          toValue: 0,
          duration: 250,
          useNativeDriver: true
        })
      ]).start(() => {
        setIsVisible(false)
      })
    }
  }, [isOpen])

  if (!isVisible) {
    return null
  }

  return (
    <View style={styles.container}>
      <TouchableWithoutFeedback onPress={onClose}>
        <Animated.View
          style={[
            styles.overlay,
            {
              opacity: overlayAnim.interpolate({
                inputRange: [0, 1],
                outputRange: [0, 0.5]
              })
            }
          ]}
        />
      </TouchableWithoutFeedback>

      <Animated.View
        style={[
          styles.sidebar,
          {
            transform: [{ translateX: slideAnim }]
          }
        ]}
      />
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 1000,
    elevation: 1000
  },
  overlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: colors.black
  },
  sidebar: {
    position: 'absolute',
    top: 0,
    left: 0,
    bottom: 0,
    width: SIDEBAR_WIDTH,
    backgroundColor: colors.card,
    ...Platform.select({
      ios: {
        shadowColor: colors.black,
        shadowOffset: { width: 4, height: 0 },
        shadowOpacity: 0.3,
        shadowRadius: 8
      },
      android: {
        elevation: 16
      }
    })
  }
})

export default Sidebar
