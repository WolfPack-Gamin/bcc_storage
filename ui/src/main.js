import { createApp } from 'vue'
import App from './App.vue'
import mdiVue from 'mdi-vue/v3'
import {
  mdiCursorMove,
  mdiCloseThick
} from '@mdi/js'

createApp(App).use(mdiVue, {
    icons: {
      mdiCursorMove,
      mdiCloseThick
    }
  }).mount('#app')
