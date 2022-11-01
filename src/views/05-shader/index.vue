<template>
  <div>
    <canvas ref="sceneRef" class="container" />
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import * as dat from 'dat.gui'
import { addWindowResizeEvent } from '../../utils/three-helper'
// // @ts-ignore;
// import rawFragmentShader from './raw-shader-glsl/fragment.glsl?raw'
// // @ts-ignore;
// import rawVertexShader from './raw-shader-glsl/vertex.glsl?raw'

// @ts-ignore;
import fragmentShader from './shader-glsl/fragment.glsl?raw'
// @ts-ignore;
import vertexShader from './shader-glsl/vertex.glsl?raw'

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

  // ## Scene
  const scene = new THREE.Scene();

  // ## Camera
  const camera = new THREE.PerspectiveCamera(75, aspect, .1, 1000);
  camera.position.set(1, 0, 5);
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
  const textureLoader = new THREE.TextureLoader();

  // const materail = new THREE.RawShaderMaterial({
  //   side: THREE.DoubleSide,
  //   vertexShader: rawVertexShader,
  //   fragmentShader: rawFragmentShader,
  //   uniforms: {
  //     uFrequency: { value: new THREE.Vector2(10, 5)},
  //     uTime: { value: 0 },
  //     uColor: { value: new THREE.Color('orange')},
  //     uTexture: { value: textureLoader.load('/public/images/flag.png')}
  //   }
  // })

  const materail = new THREE.ShaderMaterial({
    side: THREE.DoubleSide,
    vertexShader: vertexShader,
    fragmentShader: fragmentShader,
    uniforms: {
      uFrequency: { value: new THREE.Vector2(10, 5)},
      uTime: { value: 0 },
      uColor: { value: new THREE.Color('orange')},
      uTexture: { value: textureLoader.load('/public/images/flag.png')}
    }
  })

  const geometry = new THREE.PlaneBufferGeometry(1, 1, 32, 32);
  const count = geometry.attributes.position.count;
  const randoms = new Float32Array(count);

  for(let i = 0; i < count; i++){
    randoms[i] = Math.random();
  }
  geometry.setAttribute('aRandom', new THREE.BufferAttribute(randoms, 1));


  const mesh = new THREE.Mesh(geometry, materail);
  mesh.scale.y = 2/ 3;

  scene.add(mesh)
  
  const clock = new THREE.Clock();
  function tick() {
    const elapsedTime = clock.getElapsedTime();

    controls.update();
    renderer.render(scene, camera)
    materail.uniforms.uTime.value = elapsedTime;
    requestAnimationFrame(tick)
  }

  // 开始渲染
  tick();


  const gui = new dat.GUI();
  gui.add(materail.uniforms.uFrequency.value, 'x', 0, 20, .01).name('frequencyX')
  gui.add(materail.uniforms.uFrequency.value, 'y', 0, 20, .01).name('frequencyY')

})

</script>

<style lang="less">
.container {
  width: 100vw;
  height: 100vh;
}
</style>