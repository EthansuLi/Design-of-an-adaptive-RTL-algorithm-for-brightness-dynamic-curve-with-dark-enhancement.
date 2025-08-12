# Design-of-an-adaptive-RTL-algorithm-for-brightness-dynamic-curve-with-dark-enhancement.

An adaptive dark enhancement dynamic brightness curve RTL algorithm is designed. The curve is dynamically updated according to the input of each frame. The curve is similar to gamma enhancement in the low brightness range of a frame image and parameter suppression in the high brightness area. When a pure dark video stream is input, the curve changes to a pure gamma mapping, and when a bright video stream is input, the curve becomes linear.
一种自适应的暗部增强的亮度动态曲线RTL算法设计, 根据每一帧的输入动态更新该曲线，曲线在一帧图像的低亮度范围类似gamma增强，高亮度区域进行参数压制，输入纯暗视频流，则该曲线变化为纯gamma映射，输入高亮视频流，则曲线变为线性
