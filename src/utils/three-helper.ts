import type { WebGLRenderer, PerspectiveCamera } from 'three';

export const onWindowResize = (renderer:WebGLRenderer, camera:PerspectiveCamera) => {
  return () => {
    const { innerHeight, innerWidth, devicePixelRatio } = window;
    renderer.setSize(innerHeight, innerWidth);
    renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
    
    camera.aspect = innerWidth/innerHeight;
    camera.updateProjectionMatrix();
  }
}