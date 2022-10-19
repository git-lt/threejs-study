<template>
  <div>
    <canvas ref="sceneRef" class="container" />
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue'
import { Mesh, Group, Fog, Color, PerspectiveCamera, AxesHelper, Scene, WebGLRenderer, AmbientLight, MeshLambertMaterial, SphereGeometry, TorusGeometry, IcosahedronGeometry, MeshToonMaterial, Vector3 } from 'three'
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
  // 添加背景和雾
  scene.background = new Color(0x1a1a1a);
  scene.fog = new Fog(0x1a1a1a, 1, 1000);

  // 设置大小和像素比
  renderer.setSize(sizes.width, sizes.height);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

  // 视野的大小，默认是45
  const fov = 40;
  // 渲染的起始位置。默认0.1
  const near = 0.1;
  // 渲染的最大位置，默认1000
  const fav = 1000;
  // 视野比例
  const aspect = sizes.width/ sizes.height;

  // ## 相机
  const camera = new PerspectiveCamera(fov, aspect, near, fav);
  camera.position.set(20, 100, 450);
  camera.lookAt(0,0,0);

  // 显示坐标原点
  const axis = new AxesHelper(40);
  scene.add(axis);

  // 相机控制器
  const controls = new OrbitControls(camera, canvas);
  controls.enableDamping = true;
  

  // ## 光源
  const light = new AmbientLight(0xdeedff, 1.5);
  scene.add(light);


  // 创建星球球体
  const sphereGeometry = new SphereGeometry(80, 32, 32)
  const sphereMaterial = new MeshLambertMaterial({
    color: 0x03c03c,
    // 以网格显示
    wireframe: true
  })
  const sphereMesh = new Mesh(sphereGeometry, sphereMaterial);
  scene.add(sphereMesh);

  // 星球轨道环
  const torusGeometry = new TorusGeometry(150, 8, 2, 120);
  const torusMaterial = new MeshLambertMaterial({
    color: 0x40a9ff,
    wireframe: true,
  })
  const torusMesh = new Mesh(torusGeometry, torusMaterial);
  // 沿x轴旋转90度 (本地坐标)
  torusMesh.rotation.x = Math.PI / 2;
  // 沿y轴旋转9度 (本地坐标)
  torusMesh.rotation.y = Math.PI / 2 * -0.1;
  scene.add(torusMesh);

  // 创建卫星
  const icoGeometry = new IcosahedronGeometry(16, 0);
  const icoMaterial = new MeshToonMaterial({ color: 0xfffc00});
  const satellite = new Mesh(icoGeometry, icoMaterial);
  scene.add(satellite);

  // 创建500个星星
  const stars = new Group();
  for(let i = 0; i<500; i++){
    const geometry = new IcosahedronGeometry(Math.random()*2, 0);
    const material = new MeshToonMaterial({ color: 0xeeeeee })
    const mesh = new Mesh(geometry, material);
    // 随机位置
    mesh.position.set((Math.random() - 0.5 )*700, (Math.random() - 0.5 )*700, (Math.random() - 0.5 )*700);
    // 随机角度
    mesh.rotation.set(Math.random()*2*Math.PI,Math.random()*2*Math.PI,Math.random()*2*Math.PI);
    stars.add(mesh);
  }
  scene.add(stars);


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


  let rot = 0;
  const axisPoint = new Vector3(0, 0, 1)
  function tick() {

    rot += Math.random() * 0.8;
    const radian = (rot * Math.PI) / 180;

    // 星球
    sphereMesh && (sphereMesh.rotation.y += .005);
    // 星环
    torusMesh && torusMesh.rotateOnAxis(axisPoint, Math.PI / 400);
    // 卫星
    satellite.position.set(250*Math.sin(radian), 100 * Math.cos(radian), -100 * Math.cos(radian));
    satellite.rotation.x += 0.05;
    satellite.rotation.y += 0.05;
    satellite.rotation.z -= 0.05;
    // 星星
    stars.rotation.y += 0.009;
    stars.rotation.z -= 0.003;
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