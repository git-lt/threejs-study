import type { RouteRecordRaw } from 'vue-router'
import Introduce from './views/introduce.vue'
import Basic from './views/basic.vue'
import Shadow from './views/shadow.vue'

export const routes:RouteRecordRaw[] = [
  {'path': '/introduce', component: Introduce },
  {'path': '/basic', component: Basic },
  {'path': '/shadow', component: Shadow },
]

