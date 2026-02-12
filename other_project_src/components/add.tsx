import React from 'react'
import { StyleSheet, TouchableOpacity } from 'react-native'
import { Ionicons } from '@expo/vector-icons'
import { colors, spacing } from '../utils/theme'

interface Props {
  onAdd: () => void
}

const Add = (props: Props): React.ReactElement => {
  const handleAdd = props.onAdd
  return (
    <TouchableOpacity style={styles.add} onPress={handleAdd}>
      <Ionicons name="add-circle" size={32} color={colors.primary} />
    </TouchableOpacity>
  )
}

const styles = StyleSheet.create({
  add: {
    padding: spacing.xs
  }
})

export default Add
