"use client";

import React, { useEffect, useRef, useState } from "react";

interface BoomerangVideoBgProps {
  src: string;
}

export default function BoomerangVideoBg({ src }: BoomerangVideoBgProps) {
  const videoRef = useRef<HTMLVideoElement | null>(null);
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const framesRef = useRef<HTMLCanvasElement[]>([]);
  const [isCapturing, setIsCapturing] = useState(true);
  const [capturedCount, setCapturedCount] = useState(0);
  const [isComplete, setIsComplete] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;

    let animFrameId: number;
    let lastTime = -1;
    let isCapturingActive = true;
    
    // Fix capture to 30fps max to avoid massive memory usage on high refresh rate displays
    const TARGET_FPS = 30;
    const FRAME_INTERVAL = 1000 / TARGET_FPS;
    let lastCaptureTime = 0;

    const handlePlay = () => {
      setLoading(false);
      
      const originalWidth = video.videoWidth || 960;
      const originalHeight = video.videoHeight || 540;
      const targetWidth = Math.min(960, originalWidth);
      const targetHeight = (targetWidth / originalWidth) * originalHeight;

      const captureFrame = async (timestamp: number) => {
        if (!isCapturingActive || video.paused || video.ended || video.currentTime >= 8) {
          if (isCapturingActive && video.currentTime >= 8) {
            handleEnded();
          }
          return;
        }

        // Throttle capture to TARGET_FPS
        if (timestamp - lastCaptureTime >= FRAME_INTERVAL) {
          if (video.currentTime !== lastTime) {
            lastTime = video.currentTime;
            lastCaptureTime = timestamp;

            const offscreen = document.createElement("canvas");
            offscreen.width = targetWidth;
            offscreen.height = targetHeight;
            const ctx = offscreen.getContext("2d", { alpha: false });
            
            if (ctx) {
              ctx.drawImage(video, 0, 0, targetWidth, targetHeight);
              framesRef.current.push(offscreen);
              setCapturedCount(framesRef.current.length);
            }
          }
        }

        animFrameId = requestAnimationFrame(captureFrame);
      };

      animFrameId = requestAnimationFrame(captureFrame);
    };

    const handleEnded = () => {
      if (!isCapturingActive) return;
      isCapturingActive = false;
      setIsCapturing(false);
      setIsComplete(true);
    };

    video.addEventListener("play", handlePlay);
    video.addEventListener("ended", handleEnded);

    if (video.readyState >= 3) {
      handlePlay();
    }

    return () => {
      isCapturingActive = false;
      video.removeEventListener("play", handlePlay);
      video.removeEventListener("ended", handleEnded);
      cancelAnimationFrame(animFrameId);
    };
  }, [src]);

  // Boomerang Loop Rendering
  useEffect(() => {
    if (!isComplete || framesRef.current.length === 0) return;

    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext("2d", { alpha: false });
    if (!ctx) return;

    const firstFrame = framesRef.current[0];
    canvas.width = firstFrame.width;
    canvas.height = firstFrame.height;

    let loopFrameId: number;
    let lastRenderTime = 0;
    const interval = 1000 / 30; // Strict 30 FPS playback
    
    // Start `t` at `totalFrames - 1` so that the very first canvas frame 
    // is the end of the video, and it plays backwards from there seamlessly.
    let t = framesRef.current.length > 1 ? framesRef.current.length - 1 : 0; 

    const renderLoop = (timestamp: number) => {
      if (!lastRenderTime) lastRenderTime = timestamp;
      const elapsed = timestamp - lastRenderTime;

      if (elapsed >= interval) {
        lastRenderTime = timestamp - (elapsed % interval);

        const totalFrames = framesRef.current.length;
        if (totalFrames > 1) {
          let index = t % (2 * (totalFrames - 1));
          if (index >= totalFrames) {
            index = 2 * (totalFrames - 1) - index;
          }

          const frameCanvas = framesRef.current[index];
          if (frameCanvas) {
            ctx.drawImage(frameCanvas, 0, 0);
          }
          t++;
        }
      }

      loopFrameId = requestAnimationFrame(renderLoop);
    };

    loopFrameId = requestAnimationFrame(renderLoop);

    return () => {
      cancelAnimationFrame(loopFrameId);
    };
  }, [isComplete]);

  return (
    <div className="absolute inset-0 z-0 scale-[1.08] origin-center overflow-hidden bg-black">
      {/* Loading state indicator - subtle overlay */}
      {loading && (
        <div className="absolute inset-0 z-30 flex items-center justify-center bg-black/40 backdrop-blur-md">
          <div className="flex flex-col items-center gap-3">
            <div className="h-8 w-8 animate-spin rounded-full border-2 border-white/20 border-t-white" />
            <span className="text-xs font-light tracking-widest text-white/60 uppercase">
              Loading stream...
            </span>
          </div>
        </div>
      )}

      {/* Frame capture progress indicator (subtle indicator) */}
      {isCapturing && !loading && (
        <div className="absolute bottom-4 left-4 z-30 rounded-lg bg-black/50 px-3 py-1.5 text-[10px] font-mono text-white/60 backdrop-blur-sm">
          CAPTURING BUFFER: {capturedCount} frames
        </div>
      )}

      {/* Canvas for playback of captured frames */}
      <canvas
        ref={canvasRef}
        className="absolute inset-0 z-10 h-full w-full object-cover transition-opacity duration-300 pointer-events-none"
        style={{ opacity: isComplete ? 1 : 0 }}
      />

      {/* Video playing for the initial capture run */}
      <video
        ref={videoRef}
        src={src}
        muted
        autoPlay
        playsInline
        crossOrigin="anonymous"
        className="absolute inset-0 z-0 h-full w-full object-cover transition-opacity duration-700 pointer-events-none"
        style={{ opacity: loading ? 0 : 1 }}
      />
    </div>
  );
}
