import { createApp } from 'vue'
import { createRouter, createWebHashHistory} from 'vue-router'
import { routes } from './routes'
import App from './App.vue'
import './main.css'

const router = createRouter({
  history: createWebHashHistory(),
  routes 
})

const app = createApp(App)
app.use(router)
app.mount('#app')
