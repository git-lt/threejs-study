import type { WebGLRenderer, PerspectiveCamera } from 'three';
type Sizes = { width: number, height: number };

export const addWindowResizeEvent = (renderer:WebGLRenderer, camera:PerspectiveCamera, sizes: Sizes) => {
  window.addEventListener('resize', () => {
    const { innerHeight, innerWidth, devicePixelRatio } = window;
    sizes.width = innerWidth;
    sizes.height = innerHeight;
    renderer.setSize(innerWidth, innerHeight );
    renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
    
    camera.aspect = innerWidth/innerHeight;
    camera.updateProjectionMatrix();
  })
}