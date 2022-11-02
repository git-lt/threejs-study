<template>
  <div class="main-conatiner">
    <div class="menus" v-show="isHome">
      <div class="menus-inner">
        <div class="menus-item"><router-link to="/introduce">01 入门示例</router-link></div>
        <div class="menus-item"><router-link to="/basic">02 宇宙星球</router-link></div>
        <div class="menus-item"><router-link to="/shadow">03 光与影</router-link></div>
        <div class="menus-item"><router-link to="/particles">04 迷失太空</router-link></div>
        <div class="menus-item"><router-link to="/shader">05 着色器基础</router-link></div>
        <div class="menus-item"><router-link to="/shader-pattern">06 着色器图案</router-link></div>
      </div>
    </div>
    <router-view></router-view>
  </div>
</template>

<script lang="ts" setup>
import { useRoute } from 'vue-router'
import { ref, watch } from 'vue'

const route = useRoute();

const isHome = ref(true);

watch(
  () => route.path,
  async path => {
    isHome.value = path === '/';
  }
)

</script>

<style lang="less">
html, body {
  overflow: hidden;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  height: 100%;
  width: 100%;
}
.main-conatiner {
  height: 100%;
  width: 100%;
}

.menus {
  &-inner {
    width: 200px;
    display: flex;
    flex-direction: column;
  }
  &-item {
  padding: 8px 16px;
  text-align: left;
    a {
      text-decoration: none;
    }
  }
}


</style>
