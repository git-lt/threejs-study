<template>
  <div>
    <canvas ref="sceneRef" class="container" />
    <div class="title-zone">
      <h1 class="title">GRAVITY</h1>
      <h2 class="subtitle">迷失太空</h2>
    </div>
  </div>
</template>
<script lang="ts" setup>
import { ref, onMounted } from 'vue'
import { 
  PerspectiveCamera, 
  AxesHelper, 
  Scene, 
  WebGLRenderer, 
  Sprite, 
  SpriteMaterial, 
  BufferGeometry, 
  PointsMaterial, 
  Color, 
  Float32BufferAttribute, 
  Points,
  TextureLoader,
  CanvasTexture,
  SphereGeometry,
  AdditiveBlending,
  Texture,
  MeshLambertMaterial,
  FogExp2,
  PointLight,
  AmbientLight,
  Group,
  PointLightHelper,
 } from 'three'
import type { PointsMaterialParameters} from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import * as dat from 'dat.gui'
import { GLTF, GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader'
import { addWindowResizeEvent } from '../utils/three-helper'

const sceneRef = ref<HTMLCanvasElement>();

onMounted(() => {
  const canvas = sceneRef.value;

  const sizes = {
    width: window.innerWidth,
    height: window.innerHeight,
  }
  const aspect = sizes.width / sizes.height;

  // ## Renderer
  const renderer = new WebGLRenderer({ canvas })
  renderer.setSize(sizes.width, sizes.height);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

  // ## Scene
  const scene = new Scene();

  // ## Camera
  const camera = new PerspectiveCamera(45, aspect, .1, 1000);
  camera.position.z = 120;
  camera.lookAt(0,0,0);
  scene.add(camera);

  // 显示坐标原点
  // const axis = new AxesHelper(40);
  // scene.add(axis);

  // Controls
  const controls = new OrbitControls(camera, canvas);
  controls.enableDamping = true;

  // 页面适配
  addWindowResizeEvent(renderer, camera, sizes);
  
  function tick() {
    controls.update();
    renderer.render(scene, camera)
    requestAnimationFrame(tick)
  }

  // 开始渲染
  tick();

/**
 * 使用THREE.Sprite创建粒子
 * 适用于少量粒子效果，便于控制每个粒子效果
 */
  const createParticlesBySprite = () => {
   for (let x = -15; x < 15; x++){
    for (let y = -10; y < 10; y++){
      // 随机颜色
      const color = Math.random() * 0xffffff;
      const sprite = new Sprite( new SpriteMaterial({ color }))
      // 设置位置
      sprite.position.set(x*4, y*4, 0);
      scene.add(sprite);
    }
   }
  }
  // createParticlesBySprite();

  /**
   * 使用 THREE.Points 创建粒子
   * 适用于大量粒子，性能更好
   */
  const createParticlesByPoints = () =>{
    const geometry = new BufferGeometry();
    const material = new PointsMaterial({
      // 大小
      size: 4,
      // 是否使用顶点着色
      vertexColors: true,
      color: 0xffffff,
    })

    // 生成点集合 和 颜色集合
    let points = [];
    let colors = [];
    for(let x = -15; x < 15; x++){
      for(let y = -10; y < 10; y++){
        points.push(x*4, y * 4, 0)
        const color = new Color(Math.random() * 0xffffff );
        colors.push(color.r, color.g, color.b);
      }
    }
    const position = new Float32BufferAttribute(points, 3)
    const color = new Float32BufferAttribute(colors, 3);
    
    // 给几何体设置 点 和 点的颜色
    geometry.attributes.position = position;
    geometry.attributes.color = color;

    const particles = new Points(geometry, material)
    scene.add(particles)
  }
  // createParticlesByPoints();

  /**
   * 使用 GUI可视化调试工具 控制粒子的样式
   */
  interface Ctrls {
    size: number;
    transparent: boolean;
    opacity: number;
    vertexColors: boolean;
    color: number;
    vertexColor: number;
    sizeAttenuation: boolean;
    rotate: boolean;
    redraw: () => void;
  }
  
  const createStyledParticlesByPoints = (ctrls: Omit<Ctrls, 'rotate' | 'redraw'> ) => {
    const geometry = new BufferGeometry();
    const materail = new PointsMaterial({
      size: ctrls.size,
      transparent: ctrls.transparent,
      opacity: ctrls.opacity,
      color: new Color(ctrls.color),
      vertexColors: ctrls.vertexColors,
      sizeAttenuation: ctrls.sizeAttenuation
    })

    // 生成点集合 和 颜色集合
    let points = [];
    let colors = [];
    for(let x = -15; x < 15; x++){
      for(let y = -10; y < 10; y++){
        points.push(x*4, y * 4, 0)
        const color = new Color(Math.random() * 0xffffff );
        colors.push(color.r, color.g, color.b);
      }
    }
    const position = new Float32BufferAttribute(points, 3)
    const color = new Float32BufferAttribute(colors, 3);
    
    // 给几何体设置 点 和 点的颜色
    geometry.attributes.position = position;
    geometry.attributes.color = color;

    const particles = new Points(geometry, materail)
    particles.name = 'particles'
    scene.add(particles)
  }

  const ctrls:Ctrls = {
    size: 5,
    transparent: true,
    opacity: .6,
    vertexColors: true,
    color: 0xffffff,
    vertexColor: 0x00ff00,
    sizeAttenuation: true,
    rotate: true,
    redraw: () => {
      const particlesObject = scene.getObjectByName('particles')
      particlesObject && scene.remove(particlesObject);

      createStyledParticlesByPoints({
        size: ctrls.size,
        transparent: ctrls.transparent,
        opacity: ctrls.opacity,
        vertexColors: ctrls.vertexColors,
        sizeAttenuation: ctrls.sizeAttenuation,
        color: ctrls.color,
        vertexColor: ctrls.vertexColor
      })
    }
  }

  const gui = new dat.GUI();
  gui.add(ctrls, 'size', 0, 10, .001).onChange(ctrls.redraw).name('粒子大小');
  gui.add(ctrls, 'transparent').onChange(ctrls.redraw).name('开启透明');
  gui.add(ctrls, 'opacity', 0, 1, .001).onChange(ctrls.redraw).name('透明度');
  gui.add(ctrls, 'vertexColors').onChange(ctrls.redraw).name('使用自定义颜色')
  gui.addColor(ctrls, 'color').onChange(ctrls.redraw).name('粒子颜色');
  gui.addColor(ctrls, 'vertexColor').onChange(ctrls.redraw).name('随机色种子')
  gui.add(ctrls, 'sizeAttenuation').onChange(ctrls.redraw).name('大小随景深衰减')
  gui.hide();
 
  // ctrls.redraw();
  // gui.show();

  /**
   * 使用 canvas 或 图片 做为 粒子纹理
   */
  const createParticlesByCanvas = () => {
    const createCanvasTexture = () => {
      const canvas = document.createElement('canvas');
      const ctx = canvas.getContext('2d') as CanvasRenderingContext2D;
      canvas.width = 300;
      canvas.height = 300;
      ctx.lineWidth = 10;
      ctx.beginPath();
      ctx.moveTo(170, 120);
      const grd = ctx.createLinearGradient(0, 0, 170, 0);
      grd.addColorStop(0, 'black');
      grd.addColorStop(.3, 'magenta');
      grd.addColorStop(.5, 'blue');
      grd.addColorStop(.6, 'green');
      grd.addColorStop(.8, 'yellow');
      grd.addColorStop(1, 'red');
      ctx.strokeStyle = grd;
      ctx.arc(120, 120, 50, 0, Math.PI * 2);
      ctx.stroke();
      
      // 使用 Canvas 作为纹理
      const texture = new CanvasTexture(canvas);
      texture.needsUpdate = true;
      return texture;
    }
    // const texture = new TextureLoader()

    const createParticles = (parameters: PointsMaterialParameters) => {
      const geometry = new BufferGeometry();
      const materail = new PointsMaterial({
        ...parameters,
        // 正常显示叠加效果
        depthTest: true,
        // 正常显示透明效果
        depthWrite: false,
      });

      let points = [];
      const range = 500;
      for(let i = 0; i< 500; i++){
        points.push(
          Math.random() * range - range /2,
          Math.random() * range - range /2,
          Math.random() * range - range /2,
        )
      }
      const position = new Float32BufferAttribute(points, 3);
      geometry.attributes.position = position;
      const particles = new Points(geometry, materail);
      scene.add(particles);
      
    }
  
    const texture = new TextureLoader().load('/public/images/heart.png');

    createParticles({
      size: 40,
      transparent: true,
      opacity: 1,
      // 使用 canvas 作为纹理
      map: createCanvasTexture(),
      // 使用 图片 作为纹理
      // map: texture,
      sizeAttenuation: true,
      color: 0xffffff,
    })
  }

  // createParticlesByCanvas();

  /**
   * 使用 几何体 作为粒子纹理
   */
  const createParticlesByGeomery = () => {
    const generateSprite = () => {
      const canvas = document.createElement('canvas');
      canvas.width = 16;
      canvas.height = 16;
      const context = canvas.getContext('2d') as CanvasRenderingContext2D;
      const gradient = context.createRadialGradient(
        canvas.width / 2,
        canvas.height / 2,
        0,
        canvas.width / 2,
        canvas.height / 2,
        canvas.width / 2
      );
      gradient.addColorStop(0, 'rgba(255, 255, 255, 1)');
      gradient.addColorStop(0.2, 'rgba(0, 255, 0, 1)');
      gradient.addColorStop(0.4, 'rgba(0, 120, 20, 1)');
      gradient.addColorStop(1, 'rgba(0, 0, 0, 1)');
      context.fillStyle = gradient;
      context.fillRect(0, 0, canvas.width, canvas.height);
      const texture = new Texture(canvas);
      texture.needsUpdate = true;
      return texture;
    }

    const sphereGeometry = new SphereGeometry(15, 32, 16);
    const material = new PointsMaterial({
      color: 0xffffff,
      size: 3,
      transparent: true,
      blending: AdditiveBlending,
      map: generateSprite(),
      depthWrite: false,
    })

    const particles = new Points(sphereGeometry, material);
    scene.add(particles);
  }
  // createParticlesByGeomery();


  /**
   * 迷失太空
   */
  const lostInSpace = () => {
    // controls.dispose();
    camera.position.z = 10;
    
    const rand  = (min:number, max:number) => min + Math.random() * (max - min);
    let astronaut:Group;
    let t = 0;

    const loader = new GLTFLoader();
    loader.load('/public/models/astronaut.glb', obj => {
      astronaut = obj.scene;
      // @ts-ignore
      astronaut.material = new MeshLambertMaterial();
      astronaut.scale.set(.05, .05, .05);
      astronaut.position.z = -10;
      scene.add(astronaut);
    })

    const geometry = new BufferGeometry();
    const texture = new TextureLoader().load('/public/images/particle.png');

    const materail = new PointsMaterial({
      color: 0xffffff,
      size: 10,
      alphaTest: .8,
      // vertexColors: true,
      map: texture,
    })

    // 将点随机生成在环形空间，沿z轴负方向沿伸
    const points:number[] = [];
    const colors:number[] = [];
    for(let i = 0; i<1000; i++){
      points.push(
        rand(20, 30) * Math.cos(i),
        rand(20, 30) * Math.sin(i),
        rand(-1500, 0),
      )
      const color = new Color(Math.random() * 0xffffff);
      colors.push(color.r, color.g, color.b)
    }
    geometry.attributes.position = new Float32BufferAttribute(points, 3);
    geometry.attributes.color = new Float32BufferAttribute(colors, 3);

    const particles = new Points(geometry, materail);
    scene.add(particles);

    // 雾
    // 添加黑色指数雾，近亮远暗效果
    scene.fog = new FogExp2(0x000000, .005);

    // 灯光
    const pointLight1 = new PointLight('#fffaeb', 1.5);
    const pointLight2 = new PointLight(0xffffff, -1);
    const pointLight3 = new PointLight(0xffffff, .2);
    const ambientLight = new AmbientLight(0xffffff, .02);
    
    pointLight1.position.set(-50, -50, 75);
    pointLight2.position.set(50, 50, 75);
    pointLight3.position.set(25, 50, 200);

    scene.add(pointLight1)
    scene.add(pointLight2)
    scene.add(pointLight3)
    scene.add(ambientLight)

    // 粒子动画
    // 1. 整体晃动 + 向z正向移动
    // 2. 单个粒子更新z轴位置，并向z正向移动
    const particlesAnimate = () => {
      // 晃动
      particles.position.x = .2 * Math.cos(t);
      particles.position.y = .2 * Math.cos(t);
      // 整体旋转
      particles.rotation.z += .015;

      // camera.lookAt(particles.position);
      // 遍历所有的粒子
      for (let i = 0; i < points.length; i++) {
        // 只更新z轴的位置 
        if ((i + 1) % 3 === 0) {
          const dist = points[i] - camera.position.z;
          // 如果点的位置大于相机的位置
          // 则重置点在z轴的位置到 -1000 到 -500 之间
          if (dist >= 0) points[i] = rand(-1000, -500);
          // 并向正向移动
          points[i] += 1.52;
          const _vertices = new Float32BufferAttribute(points, 3);
          // 重新设置几何顶点
          geometry.attributes.position = _vertices;
        }
      }
      // @ts-ignore;
      particles.geometry.verticesNeedUpdate = true;
    }

    // 宇航员动画
    // 1. z轴来回运动
    // 2. 旋转动画
    const astronautAnimate = () => {
      if(!astronaut) return;
      camera.lookAt(astronaut.position);
      // z轴悠悠
      astronaut.position.z = -.8 * Math.sin(t);
      // astronaut.position.z = 0.08 * Math.sin(t) + (camera.position.z - 0.2);
      // 旋转
      astronaut.rotation.x += .015;
      astronaut.rotation.y += .015;
      astronaut.rotation.z += .01;
    }

    const tick = () => {
      particlesAnimate();
      astronautAnimate();
      renderer.render(scene, camera);
      requestAnimationFrame(tick);
      t += 0.01;
    }

    tick();
    
    window.addEventListener('mousemove', e => {
      const cx = window.innerWidth / 2;
      const cy = window.innerHeight / 2;
      const dx = -1 * ((cx - e.clientX) / cx);
      const dy = -1 * ((cy - e.clientY) / cy);
      camera.position.x = dx * .5;
      camera.position.y = dy * .5;
      astronaut.position.x = dx * .5;
      astronaut.position.y = dy * .5;
    })
  }
  lostInSpace();
})

</script>

<style lang="less">
.container {
  width: 80vw;
  height: 75vh;
}
@font-face {
  font-family: exc;
  src: url('/public/fonts/exc.ttf');
}
.title-zone {
  position: fixed;
  bottom: 0;
  left: 0;
  z-index: 10;
  width: 100%;
  height: 200px;
  padding-bottom: 50px;
  font-family: exc;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  
  .title {
    font-size: 56px;
    color: #fff;
    font-weight: 600;
    margin-bottom: 24px;
    text-shadow: 1px 1px 1px #fffc00, 0px 2px 2px #fffc00, 0px 4px 8px #fffc00;
    animation: fadeUp 1s linear 1s;
  animation-fill-mode: forwards;
  opacity: 0;
  transform: translateY(20px);
  }
  .subtitle {
    font-size: 40px;
    color: rgba(255, 255, 255, 1);
    text-align: center;
    font-weight: 400;
    letter-spacing: 5px;
    animation: fadeUp 2s linear 1.5s;
    animation-fill-mode: forwards;
    opacity: 0;
    transform: translateY(20px);
  }
}

@keyframes fadeUp {
  100% {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>