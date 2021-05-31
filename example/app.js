import React from 'react'
import {
  Text,
  View,
  StyleSheet,
  PixelRatio,
  ScrollView,
} from 'react-native'

class App extends React.Component {

  constructor(props) {
    super(props)
  }

  render() {
    return (
      <ScrollView>
        <View style={[styles.container, styles.center]}>
          
          <View style={[styles.itemContainer, styles.center]}>
            <Text style={styles.textItem} >test</Text>
          </View>
        </View>
      </ScrollView>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },

  center: {
    marginTop: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },

  textItem: {
    fontSize: 30,
  },

  itemContainer: {
    marginBottom: 20,
    width: 200,
    height: 45,
    borderWidth: 1 / PixelRatio.get(),
    borderColor: 'gray',
    borderRadius: 5,
  },
})

module.exports = App

