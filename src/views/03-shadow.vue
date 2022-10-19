<template>
  <div class="shadow-page" @mousemove="onMouseMove">
    <div class="lds-roller" v-if="data.isLoading"><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div>
    <div class="loading" v-if="data.isLoading" :style="loadingStyle">
      <p>Loading</p>
    </div>
    <div class="content" :style="`visibility: ${data.isLoading ? 'hidden':'visible'}`">
      <nav 
        class="header" 
        :style="data.showPage1 ? `top: 3em; opacity: 1` : ''"
      >
        <a class="active a" @mouseleave="menuMouseEvent" @mousemove="menuMouseEvent" ><span>首页</span></a>
        <a class="a" @mouseleave="menuMouseEvent" @mousemove="menuMouseEvent" ><span>关于</span></a>
        <a class="a" @mouseleave="menuMouseEvent" @mousemove="menuMouseEvent"><span>作品</span></a>
        <a class="a" @mouseleave="menuMouseEvent" @mousemove="menuMouseEvent"><span>我的</span></a>
        <a class="a" @mouseleave="menuMouseEvent" @mousemove="menuMouseEvent"><span>更多</span></a>
        <div class="cursor" :style="cursotStyle"></div>
      </nav>
      <section class="section section-first">
        <div class="info">
          <h2 class='name'>DRAGONIR</h2>
          <h1 class='title'>THREE.JS ODESSEY</h1>
          <p class='description' :style="data.showPage1 ? 'opacity: 1;' : ''">&nbsp;</p>
        </div>
        <canvas class="webgl" ref="scene1"></canvas>
      </section>
      <section class="section section-second" ref="page2">
        <div class="second-container">
          <ul class="sub-menus">
            <li class="sub-menu" :class="{active: data.submenuActiveIndex === 0}" @click="onSubMenuClick({ x: 3.2, y: 2.8, z: 3.2 }, { y: 1 }, 0)">入门</li>
            <li class="sub-menu" :class="{active: data.submenuActiveIndex === 1}" @click="onSubMenuClick({  x: -1.4, y: 2.8, z: 4.4 }, { y: -0.1 }, 1)">基础</li>
            <li class="sub-menu" :class="{active: data.submenuActiveIndex === 2}" @click="onSubMenuClick({ x: -4.8, y: 2.9, z: 3.2 }, { y: -0.75 }, 2)">进阶</li>
          </ul>
          <p class="desc" v-show="data.submenuActiveIndex === 0">昨夜西风凋碧树。独上高楼，望尽天涯路。</p>
          <p class="desc" v-show="data.submenuActiveIndex === 1">衣带渐宽终不悔，为伊消得人憔悴。</p>
          <p class="desc" v-show="data.submenuActiveIndex === 2">众里寻他千百度，蓦然回首，那人却在灯火阑珊处。</p>
        </div>
        <canvas class="webgl" ref="scene2"></canvas>
      </section>
    </div>
  </div>
</template>
<script lang="ts" setup>
import { ref, onMounted, reactive, computed } from 'vue'
import { 
  Clock, 
  PointLight, DirectionalLight, 
  LoadingManager, PerspectiveCamera, 
  Scene, Group, WebGLRenderer, 
  MeshPhongMaterial, 
  sRGBEncoding, 
} from 'three'
// 用于加载gltf或glb格式的模型
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js'
// 用于加载压缩过的模型
import { DRACOLoader } from 'three/examples/jsm/loaders/DRACOLoader.js'
import { TWEEN } from 'three/examples/jsm/libs/tween.module.min.js';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
const scene1 = ref<HTMLCanvasElement>();
const scene2 = ref<HTMLCanvasElement>();
const page2 = ref<HTMLDivElement>();

const data = reactive({
  isLoading: true,
  loadingPositionY: 0,
  showPage1: false,
  submenuActiveIndex: 0,
  cursor: {
    x: 0,
    y: 0
  },
  mousePosition: {
    x: 0,
    y: 0,
  }
})

const loadingStyle = computed(() => {
  return  `transform: translate3d(0, ${data.loadingPositionY}, 0)`
})
const cursotStyle = computed(() => {
  const x = data.mousePosition.x;
  const y = data.mousePosition.y;
  return  `left: ${x}px; top: ${y}px;`
})



const onMouseMove = (event:MouseEvent) => {
  event.preventDefault();
  const { clientX, clientY } = event;
  data.cursor.x = clientX / window.innerWidth - 0.5;
  data.cursor.y = clientY / window.innerHeight - 0.5;
  data.mousePosition.x = clientX;
  data.mousePosition.y = clientY;
}

function menuMouseEvent(event:MouseEvent){
  const isLeave = event.type === 'mouseleave';
  const { offsetX: x, offsetY: y  } = event;
  const { offsetWidth: width, offsetHeight: height  } = event.currentTarget;
  const child = event.currentTarget.children[0];
  const walk = 20;
  const xWalk = (x / width) * (walk * 2) - walk, yWalk = (y / height) * (walk * 2) - walk;
  if(child){
    child.style.cssText = isLeave ? '' : `transform: translate(${xWalk}px, ${yWalk}px);`
  }
}

let camera2: PerspectiveCamera;

const onSubMenuClick = (position: any, rotation: any, index:number) => {
  data.submenuActiveIndex = index;

  new TWEEN.Tween(camera2.position)
    .to(position, 1800)
    .easing(TWEEN.Easing.Quadratic.InOut)
    .start()
    .onComplete(function(){
      TWEEN.remove(this);
    })

  new TWEEN.Tween(camera2.rotation)
    .to(rotation, 1800)
    .easing(TWEEN.Easing.Quadratic.InOut)
    .start()
    .onComplete(function(){
      TWEEN.remove(this);
    })
}



onMounted(() => {

  const canvas1 = scene1.value;
  const canvas2 = scene2.value;
  const page2El = page2.value;

  const sizes = {
    width: canvas1?.clientWidth || 0,
    height: canvas1?.clientHeight || 0,
  }
  // 视野比例
  const aspect = sizes.width/ sizes.height;
  const pixelRatio = Math.min(window.devicePixelRatio, 2);

  // ## 渲染器
  const renderer = new WebGLRenderer({ 
    canvas: canvas1, 
    antialias: true, 
    alpha: true, 
    powerPreference: 'high-performance' 
  })
  // 设置大小和像素比
  renderer.setSize(sizes.width, sizes.height);
  renderer.setPixelRatio(pixelRatio)
  renderer.autoClear = true;
  renderer.outputEncoding = sRGBEncoding;

  const renderer2 = new WebGLRenderer({
    canvas: canvas2,
    antialias: false,
  })
  renderer2.setSize(sizes.width, sizes.height);
  renderer2.setPixelRatio(pixelRatio)
  renderer2.outputEncoding = sRGBEncoding;

  // ## 场景
  const scene = new Scene();

  const cameraGroup = new Group();
  scene.add(cameraGroup)


  // ## 相机
  const camera = new PerspectiveCamera(35, aspect, 1, 100);
  camera.position.set(19, 1.54, -.1);
  cameraGroup.add(camera)

  camera2 = new PerspectiveCamera(35, aspect, 1, 100);
  camera2.position.set(3.2, 2.8, 3.2);
  camera2.rotation.set(0,1,0);
  scene.add(camera2);

  // 加载动画
  const loadingManager = new LoadingManager();
  loadingManager.onLoad = () => {
    const yPosition = { y: 0 };
    data.isLoading = true;
    new TWEEN.Tween(yPosition)
      .to({y: 100}, 900)
      .easing(TWEEN.Easing.Quadratic.InOut)
      .start()
      .onUpdate(() => {
        data.loadingPositionY = yPosition.y;
      })
      .onComplete(function(){
        data.isLoading = false;
        TWEEN.remove(this);
      })
    
    new TWEEN.Tween(camera.position.set(0, 4, 2))
      .to({x: 0, y: 2.4, z: 5.8}, 3500)
      .easing(TWEEN.Easing.Quadratic.InOut)
      .start()
      .onComplete(function(){
        TWEEN.remove(this);
        data.showPage1 = true;
      })
    window.scroll(0, 0);
  }

  // 灯光
  const directionLight = new DirectionalLight(0xffffff, .8);
  directionLight.position.set(-100, 0, -100);
  scene.add(directionLight);

  const fillLight = new PointLight(0x88ffee, 2.7, 4, 3);
  fillLight.position.set(30, 3, 1.8);
  scene.add(fillLight)


  // 模型加载
  const dracoLoader = new DRACOLoader();
  const gltfLoader = new GLTFLoader(loadingManager);
  dracoLoader.setDecoderPath('/draco/');
  dracoLoader.setDecoderConfig({ type: 'js'});
  gltfLoader.setDRACOLoader(dracoLoader);

  let oldMaterial = null;
  gltfLoader.load('/models/statue.glb', gltf => {
    gltf.scene.traverse(obj => {
      if(obj.isMesh){
        oldMaterial = obj.material;
        obj.material = new MeshPhongMaterial({ shininess: 100 })
      }
    })
    oldMaterial && oldMaterial.dispose();
    console.log(gltf.scene)
    scene.add(gltf.scene);
    renderer.renderLists.dispose();
  })

  // ## 页面适配
  const onWindowResize = () => {
    return () => {
      const width = canvas1?.clientWidth || 0;
      const height = canvas1?.clientHeight || 0;
      renderer.setSize(width, height);
      camera.aspect = width/height;
      camera.updateProjectionMatrix();

      renderer2.setSize(width, height);
      camera2.aspect = width/ height;
      camera2.updateProjectionMatrix();
    }
  }
  window.addEventListener('resize', onWindowResize);


  // 检测当前查看的页面
  // 当 页面2 显示 >= 5% 时，绘制场景2
  let secondContainer = false;
  const ob = new IntersectionObserver(payload => {
    secondContainer = payload[0].intersectionRatio > 0.05;
  }, { threshold: 0.05});
  ob.observe(page2El);

  
  const clock = new Clock();
  let prevTime = 0;
  function tick() {
    const elapsedTime = clock.getElapsedTime();
    const deltaTime = elapsedTime - prevTime;
    prevTime = elapsedTime;
    const parallaxY = data.cursor.y;
    const parallaxX = data.cursor.x;

    // 灯光跟随鼠标
    fillLight.position.y -= (parallaxY * 9 + fillLight.position.y - 2) * deltaTime;
    fillLight.position.x += (parallaxX * 8 - fillLight.position.x) * 2 * deltaTime;
    // 相机抖动
    cameraGroup.position.z -= (parallaxY / 3 + cameraGroup.position.z) * 2 * deltaTime;
    cameraGroup.position.x += (parallaxX / 3 - cameraGroup.position.x) * 2 * deltaTime;
    
    TWEEN.update();

    secondContainer ? renderer2.render(scene, camera2): renderer.render(scene, camera);
    
    requestAnimationFrame(tick)
  }

  // 开始渲染
  tick();
})

</script>

<style lang="less">
@import '../styles/shadow.less';
</style>