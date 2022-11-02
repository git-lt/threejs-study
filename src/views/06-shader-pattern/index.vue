<template>
  <div>
    <canvas ref="sceneRef" class="container" />
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
// import * as dat from 'dat.gui'
import { addWindowResizeEvent } from '../../utils/three-helper'
// @ts-ignore;
import fragmentShader from './shader-glsl/fragment.glsl?raw'
// @ts-ignore;
import vertexShader from './shader-glsl/vertex.glsl?raw'
import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer'
import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass'
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass'


const sceneRef = ref<HTMLCanvasElement>();

onMounted(() => {
  const canvas = sceneRef.value;

  const sizes = {
    width: window.innerWidth,
    height: window.innerHeight,
  }
  const aspect = sizes.width / sizes.height;

  // ## Renderer
  const renderer = new THREE.WebGLRenderer({ canvas })
  renderer.setSize(sizes.width, sizes.height);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
  renderer.autoClear = false;

  // ## Scene
  const scene = new THREE.Scene();
 
  // ## Camera
  const camera = new THREE.PerspectiveCamera(75, aspect, .1, 1000);
  camera.position.set(3, 1, 4);
  scene.add(camera);

  // Controls
  const controls = new OrbitControls(camera, canvas);
  controls.enableDamping = true;

  // 页面适配
  addWindowResizeEvent(renderer, camera, sizes);

  /**
   * 原始着色器材质
   * RawShaderMaterial
   */
  const materail = new THREE.ShaderMaterial({
    side: THREE.DoubleSide,
    vertexShader: vertexShader,
    fragmentShader: fragmentShader,
  })

  const geometry = new THREE.PlaneBufferGeometry(1, 1, 32, 32);
  const mesh = new THREE.Mesh(geometry, materail);
  scene.add(mesh)


  const sphereMesh = new THREE.Mesh(
    new THREE.IcosahedronBufferGeometry(1, 64),
    materail,
  )
  sphereMesh.position.setX(2);
  scene.add(sphereMesh);
  
  /**
   * 辉光效果
   */

  const renderScene = new RenderPass(scene, camera);
  const bloomPass = new UnrealBloomPass(new THREE.Vector2(window.innerWidth, window.innerHeight), 1.5, .4, .85);
  bloomPass.threshold = 0;
  bloomPass.strength = 2.2;
  bloomPass.radius = .2;
  const bloomComposer = new EffectComposer(renderer);
  bloomComposer.renderToScreen = true;
  bloomComposer.addPass(renderScene);
  bloomComposer.addPass(bloomPass);
  

  // const clock = new THREE.Clock();
  function tick() {
    // const elapsedTime = clock.getElapsedTime();
    sphereMesh && (sphereMesh.rotation.y += .01);
    sphereMesh && (sphereMesh.rotation.x += .005);

    bloomComposer && bloomComposer.render();
    controls.update();
    renderer.render(scene, camera)
    requestAnimationFrame(tick)
  }

  // 开始渲染
  tick();

  // const gui = new dat.GUI();
  // gui.add(materail.uniforms.uFrequency.value, 'x', 0, 20, .01).name('frequencyX')
  // gui.add(materail.uniforms.uFrequency.value, 'y', 0, 20, .01).name('frequencyY')

})

</script>

<style lang="less">
.container {
  width: 100vw;
  height: 100vh;
}
</style>