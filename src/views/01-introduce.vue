<template>
  <div>
    <canvas ref="sceneRef" class="container" />
  </div>
</template>
<script lang="ts" setup>
import { ref, onMounted } from 'vue'
import { Mesh, BoxGeometry, PerspectiveCamera, AxesHelper, Scene, WebGLRenderer, MeshBasicMaterial } from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
const sceneRef = ref<HTMLCanvasElement>();


onMounted(() => {
  const sizes = {
    width: window.innerWidth,
    height: window.innerHeight,
  }
  const canvas = sceneRef.value;

  // ## 渲染器
  const renderer = new WebGLRenderer({ canvas })
  // ## 场景
  const scene = new Scene();

  // 设置大小和像素比
  renderer.setSize(sizes.width, sizes.height);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

  // 视野的大小，默认是45
  const fov = 75;
  // 渲染的起始位置。默认0.1
  const near = 0.1;
  // 渲染的最大位置，默认1000
  const fav = 1000;
  // 视野比例
  const aspect = sizes.width/ sizes.height;

  // ## 相机
  const camera = new PerspectiveCamera(fov, aspect, near, fav);
  camera.position.set(3, 3, 3);
  camera.lookAt(0,0,0);

  // 显示坐标原点
  const axis = new AxesHelper(40);
  scene.add(axis);

  // 控制器
  const controls = new OrbitControls(camera, canvas);
  

  // ## 页面适配
  const onWindowResize = (renderer:WebGLRenderer, camera:PerspectiveCamera) => {
    return () => {
      const { innerHeight, innerWidth, devicePixelRatio } = window;
      renderer.setSize(innerWidth, innerHeight);
      renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
      
      camera.aspect = innerWidth/innerHeight;
      camera.updateProjectionMatrix();
    }
  }
  window.addEventListener('resize', onWindowResize(renderer, camera));

  let mesh:Mesh;
  {
    // 立方几何体（width, heigth, depth 深度, widthSegments 分段数，默认为1, heightSegments, depthSegments）
    const geometry = new BoxGeometry(1, 1, 1);
    // 基础网格材质
    const material = new MeshBasicMaterial({ color: 0x03c03c })
    // 网格体
    mesh = new Mesh(geometry, material);
    // 添加到场景
    scene.add(mesh);
  }
  
  function tick() {
    if(mesh){
      mesh.rotation.y += .02
      mesh.rotation.x += .02
    }
    controls.update();
    renderer.render(scene, camera)
    requestAnimationFrame(tick)
  }

  // 开始渲染
  tick();
})

</script>

<style>
.container {
  width: 80vw;
  height: 75vh;
}
</style>