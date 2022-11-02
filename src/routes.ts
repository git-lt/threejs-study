import type { RouteRecordRaw } from 'vue-router'
import Introduce from './views/01-introduce.vue'
import Basic from './views/02-basic.vue'
import Shadow from './views/03-shadow.vue'
import Particles from './views/04-particles.vue'
import Shader from './views/05-shader/index.vue'
import ShaderPattern from './views/06-shader-pattern/index.vue'

export const routes:RouteRecordRaw[] = [
  {'path': '/introduce', component: Introduce },
  {'path': '/basic', component: Basic },
  {'path': '/shadow', component: Shadow },
  {'path': '/particles', component: Particles },
  {'path': '/shader', component: Shader },
  {'path': '/shader-pattern', component: ShaderPattern },
]

