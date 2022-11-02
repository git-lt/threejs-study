#define PI 3.1415926535897932384626433832795

varying vec2 vUv;

// 生成随机数
float random(vec2 st){
  return fract(sin(dot(st.xy, vec2(12.0909, 78.233))) * 43758.5453123);
}

// 旋转方法
vec2 rotate(vec2 uv, float rotation, vec2 mid) {
  return vec2(
    cos(rotation) * (uv.x - mid.x) + sin(rotation) * (uv.y - mid.y) + mid.x,
    cos(rotation) * (uv.y - mid.y) - sin(rotation) * (uv.x - mid.x) + mid.y
  );
}

// 创建二维柏林噪声
vec4 permute(vec4 x) {
  return mod(((x * 34.0) + 1.0) * x, 289.0);
}

vec2 fade(vec2 t) {
  return t*t*t*(t*(t*6.0-15.0)+10.0);
}

float cnoise(vec2 P) {
  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
  vec4 ix = Pi.xzxz;
  vec4 iy = Pi.yyww;
  vec4 fx = Pf.xzxz;
  vec4 fy = Pf.yyww;
  vec4 i = permute(permute(ix) + iy);
  vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
  vec4 gy = abs(gx) - 0.5;
  vec4 tx = floor(gx + 0.5);
  gx = gx - tx;
  vec2 g00 = vec2(gx.x,gy.x);
  vec2 g10 = vec2(gx.y,gy.y);
  vec2 g01 = vec2(gx.z,gy.z);
  vec2 g11 = vec2(gx.w,gy.w);
  vec4 norm = 1.79284291400159 - 0.85373472095314 * vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
  g00 *= norm.x;
  g01 *= norm.y;
  g10 *= norm.z;
  g11 *= norm.w;
  float n00 = dot(g00, vec2(fx.x, fy.x));
  float n10 = dot(g10, vec2(fx.y, fy.y));
  float n01 = dot(g01, vec2(fx.z, fy.z));
  float n11 = dot(g11, vec2(fx.w, fy.w));
  vec2 fade_xy = fade(Pf.xy);
  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}


void main(){
  // 1
  // gl_FragColor = vec4(vUv, 1.0, 1.0);

  // 2
  // gl_FragColor = vec4(vUv, 0.0, 1.0);

  // 3 左右渐变
  // float strength = vUv.x;
  // gl_FragColor = vec4(vec3(strength), 1.0);
  // gl_FragColor = vec4(vUv.x, vUv.x, vUv.x, 1.0);

  // 4 上下渐变
  // float strength = vUv.y;
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 5 上下渐变 反向
  // float strength = 1.0 - vUv.y;
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 6 上下渐变 增强
  // float strength = vUv.y * 3.0;
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 7 百叶窗1 (mod运算)
  // float strength = mod(vUv.y * 10.0, 1.0);
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 8 百叶窗2 (mod + step 运算)
  // float strength = mod(vUv.y * 10.0, 1.0);
  // strength = step(0.5, strength);
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 9 百叶窗3 (mod + step 运算)
  // float strength = mod(vUv.y * 10.0, 1.0);
  // strength = step(0.8, strength);
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 10 斑马线 (mod + step 运算)
  // float strength = mod(vUv.x * 10.0, 1.0);
  // strength = step(0.6, strength);
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 11 网格 (相加)
  // float strength = step(0.8, mod(vUv.x * 10.0, 1.0));
  // strength += step(0.8, mod(vUv.y * 10.0, 1.0));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 12 网点 (相乘)
  // float strength = step(0.8, mod(vUv.x * 10.0, 1.0));
  // strength *= step(0.8, mod(vUv.y * 10.0, 1.0));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 13 网点 变体1 (相乘)
  // float strength = step(0.4, mod(vUv.x * 10.0, 1.0));
  // strength *= step(0.8, mod(vUv.y * 10.0, 1.0));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 14 网点 变体2 (相乘 相加)
  // float barX = step(0.4, mod(vUv.x * 10.0, 1.0)) * step(0.8, mod(vUv.y * 10.0, 1.0));
  // float barY = step(0.8, mod(vUv.x * 10.0, 1.0)) * step(0.4, mod(vUv.y * 10.0, 1.0));
  // float strength = barX + barY;
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 15 网点 变体2 (相乘 相加 偏移)
  // float barX = step(0.4, mod(v * 10.0 - 0.2, 1.0)) * step(0.8, mod(vUv.y * 10.0, 1.0));
  // float barY = step(0.8, mod(vUv.x * 10.0, 1.0)) * step(0.4, mod(vUv.y * 10.0 - 0.2, 1.0));
  // float strength = barX + barY;
  // gl_FragColor = vec4(vec3(strengtUv.xh), 1.0);

  // 16 渐变 (abs)
  // float strength = abs(vUv.x - 0.5);
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 17 渐变 (abs + min)
  // float strength = min(abs(vUv.x - 0.5), abs(vUv.y - 0.5));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 18 渐变 (abs + max)
  // float strength = max(abs(vUv.x - 0.5), abs(vUv.y - 0.5));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 19 方框 (abs + max + step)
  // float strength = step(0.2, max(abs(vUv.x - 0.5), abs(vUv.y - 0.5)));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 20 细方框 (abs + max + step)
  // float strength = step(0.2, max(abs(vUv.x - 0.5), abs(vUv.y - 0.5)));
  // strength *= 1.0 - step(0.25, max(abs(vUv.x - 0.5), abs(vUv.y - 0.5)));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 21 灰度色阶 (floor)
  // float strength = floor(vUv.x * 10.0) / 10.0;
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 22 灰度色阶网格 (floor 相乘)
  // float strength = floor(vUv.x * 10.0) / 10.0 * floor(vUv.y * 10.0) / 10.0;
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 23 噪点图
  // float strength = random(vUv);
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 24 马赛克图
  // vec2 gridUv = vec2(floor(vUv.x * 10.0) / 10.0, floor(vUv.y * 10.0) / 10.0);
  // float strength = random(gridUv);
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 25 斜马赛克图
  // vec2 gridUv = vec2(floor(vUv.x * 10.0) / 10.0, floor((vUv.y  + vUv.x * 0.5) * 10.0)  / 10.0);
  // float strength = random(gridUv);
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 26 角径向渐变
  // float strength = length(vUv);
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 27 中心径向渐变
  // float strength = distance(vUv, vec2(0.5));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 28 径向渐变反向
  // float strength = 1.0 - distance(vUv, vec2(0.5));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 29 光斑
  // float strength = 0.015 / (distance(vUv, vec2(0.5)));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 30 光斑挤压
  // float strength = 0.15 / (distance(vec2(vUv.x, (vUv.y - 0.5) * 5.0 + 0.5), vec2(0.5)));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 31 光斑挤压相乘
  // float strength = 0.15 / (distance(vec2(vUv.x, (vUv.y - 0.5) * 5.0 + 0.5), vec2(0.5)));
  // strength *= 0.15 / (distance(vec2(vUv.y, (vUv.x - 0.5) * 5.0 + 0.5), vec2(0.5)));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 32 旋转uv
  // vec2 rotatedUv = rotate(vUv, PI * 0.25, vec2(0.5));
  // float strength = 0.15 / (distance(vec2(rotatedUv.x, (rotatedUv.y - 0.5) * 5.0 + 0.5), vec2(0.5)));
  // strength *= 0.15 / (distance(vec2(rotatedUv.y, (rotatedUv.x - 0.5) * 5.0 + 0.5), vec2(0.5)));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 33 中心圆 （step distance)
  // float strength = step(0.5, distance(vUv, vec2(0.5)) + 0.2);
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 34 中心圆 （step distance)
  // float strength = abs(distance(vUv, vec2(0.5)) - 0.25);
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 35 圆环
  // float strength = step(0.02, abs(distance(vUv, vec2(0.5)) - 0.25));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 36 圆环 反色
  // float strength = 1.0 - step(0.02, abs(distance(vUv, vec2(0.5)) - 0.25));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 37 波浪
  // vec2 wavedUv = vec2(vUv.x, vUv.y + sin(vUv.x * 30.0) * 0.1);
  // float strength = 1.0 - step(0.02, abs(distance(wavedUv, vec2(0.5)) - 0.25));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 38 波浪2
  // vec2 wavedUv = vec2(vUv.x + sin(vUv.y * 30.0) * 0.1, vUv.y + sin(vUv.x * 30.0) * 0.1);
  // float strength = 1.0 - step(0.02, abs(distance(wavedUv, vec2(0.5)) - 0.25));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 39 波浪3
  // vec2 wavedUv = vec2(vUv.x + sin(vUv.y * 100.0) * 0.1, vUv.y + sin(vUv.x * 100.0) * 0.1);
  // float strength = 1.0 - step(0.02, abs(distance(wavedUv, vec2(0.5)) - 0.25));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 40 渐变
  // float angle = atan(vUv.x, vUv.y);
  // float strength = angle;
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 41 渐变
  // float angle = atan(vUv.x - 0.5, vUv.y - 0.5);
  // float strength = angle;
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 42 渐变
  // float angle = atan(vUv.x - 0.5, vUv.y - 0.5);
  // angle /= PI * 2.0;
  // angle += 0.5;
  // float angle = atan(vUv.x - 0.5, vUv.y - 0.5) / (PI * 2.0) + 0.5;
  // float strength = angle;
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 43 渐变
  // float angle = atan(vUv.x - 0.5, vUv.y - 0.5) / (PI * 2.0) + 0.5;
  // float strength = mod(angle * 20.0, 1.0);
  // gl_FragColor = vec4(vec3(strength), 1.0);


  // 44 渐变
  // float angle = atan(vUv.x - 0.5, vUv.y - 0.5) / (PI * 2.0) + 0.5;
  // float strength = sin(angle * 100.0);
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 45 渐变
  // float angle = atan(vUv.x - 0.5, vUv.y - 0.5) / (PI * 2.0) + 0.5;
  // float radius = 0.25 + sin(angle * 100.0) * 0.02;
  // float strength = 1.0 - step(0.01, abs(distance(vUv, vec2(0.5)) - radius));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 46 柏林噪声
  // float strength = cnoise(vUv * 10.0);
  // gl_FragColor = vec4(vec3(strength), 1.0);
  
  // 47 柏林噪声 - 奶牛皮肤
  // float strength = step(0.0, cnoise(vUv * 10.0));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 48 柏林噪声 - 水纹
  // float strength = 1.0 - abs(cnoise(vUv * 10.0));
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 49 柏林噪声
  // float strength = sin(cnoise(vUv * 10.0) * 20.0);
  // gl_FragColor = vec4(vec3(strength), 1.0);

  // 50 柏林噪声
  float strength = step(0.9, sin(cnoise(vUv * 10.0) * 20.0));

  vec3 blackColor = vec3(0.0);
  vec3 uvColor = vec3(vUv, 0.2);
  vec3 mixedColor = mix(blackColor, uvColor, strength);

  gl_FragColor = vec4(mixedColor, 1.0);

}