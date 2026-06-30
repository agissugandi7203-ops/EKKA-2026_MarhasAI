"use client";

import { useCallback, useEffect, useMemo, useRef, useState, memo, type ReactNode, type CSSProperties } from "react";
import "./LogoLoop.css";

const ANIMATION_CONFIG = { SMOOTH_TAU: 0.25, MIN_COPIES: 2, COPY_HEADROOM: 2 };

const toCssLength = (value: number | string | undefined): string | undefined =>
  typeof value === "number" ? `${value}px` : (value ?? undefined);

interface LogoNodeItem {
  node: ReactNode;
  title?: string;
  href?: string;
  ariaLabel?: string;
}

interface LogoImageItem {
  src: string;
  srcSet?: string;
  sizes?: string;
  width?: number;
  height?: number;
  alt?: string;
  title?: string;
  href?: string;
}

export type LogoItem = LogoNodeItem | LogoImageItem;

interface LogoLoopProps {
  logos: LogoItem[];
  speed?: number;
  direction?: "left" | "right" | "up" | "down";
  width?: number | string;
  logoHeight?: number;
  gap?: number;
  pauseOnHover?: boolean;
  hoverSpeed?: number;
  fadeOut?: boolean;
  fadeOutColor?: string;
  scaleOnHover?: boolean;
  ariaLabel?: string;
  className?: string;
  style?: CSSProperties;
}

function LogoLoopInner({
  logos,
  speed = 120,
  direction = "left",
  width = "100%",
  logoHeight = 28,
  gap = 32,
  pauseOnHover,
  hoverSpeed,
  fadeOut = false,
  fadeOutColor,
  scaleOnHover = false,
  ariaLabel = "Partner logos",
  className,
  style,
}: LogoLoopProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const trackRef = useRef<HTMLDivElement>(null);
  const seqRef = useRef<HTMLUListElement>(null);

  const [seqWidth, setSeqWidth] = useState(0);
  const [seqHeight, setSeqHeight] = useState(0);
  const [copyCount, setCopyCount] = useState(ANIMATION_CONFIG.MIN_COPIES);
  const [isHovered, setIsHovered] = useState(false);

  const effectiveHoverSpeed = useMemo(() => {
    if (hoverSpeed !== undefined) return hoverSpeed;
    if (pauseOnHover === true) return 0;
    if (pauseOnHover === false) return undefined;
    return 0;
  }, [hoverSpeed, pauseOnHover]);

  const isVertical = direction === "up" || direction === "down";

  const targetVelocity = useMemo(() => {
    const magnitude = Math.abs(speed);
    let directionMultiplier: number;
    if (isVertical) {
      directionMultiplier = direction === "up" ? 1 : -1;
    } else {
      directionMultiplier = direction === "left" ? 1 : -1;
    }
    const speedMultiplier = speed < 0 ? -1 : 1;
    return magnitude * directionMultiplier * speedMultiplier;
  }, [speed, direction, isVertical]);

  // Resize observer
  useEffect(() => {
    const updateDimensions = () => {
      const containerWidth = containerRef.current?.clientWidth ?? 0;
      const sequenceRect = seqRef.current?.getBoundingClientRect?.();
      const sequenceWidth = sequenceRect?.width ?? 0;
      const sequenceHeight = sequenceRect?.height ?? 0;

      if (isVertical) {
        if (sequenceHeight > 0) {
          setSeqHeight(Math.ceil(sequenceHeight));
          const viewport = containerRef.current?.clientHeight ?? sequenceHeight;
          const copiesNeeded = Math.ceil(viewport / sequenceHeight) + ANIMATION_CONFIG.COPY_HEADROOM;
          setCopyCount(Math.max(ANIMATION_CONFIG.MIN_COPIES, copiesNeeded));
        }
      } else if (sequenceWidth > 0) {
        setSeqWidth(Math.ceil(sequenceWidth));
        const copiesNeeded = Math.ceil(containerWidth / sequenceWidth) + ANIMATION_CONFIG.COPY_HEADROOM;
        setCopyCount(Math.max(ANIMATION_CONFIG.MIN_COPIES, copiesNeeded));
      }
    };

    if (!window.ResizeObserver) {
      window.addEventListener("resize", updateDimensions, { passive: true });
      updateDimensions();
      return () => window.removeEventListener("resize", updateDimensions);
    }

    const observers: ResizeObserver[] = [];
    [containerRef, seqRef].forEach((ref) => {
      if (ref.current) {
        const observer = new ResizeObserver(updateDimensions);
        observer.observe(ref.current);
        observers.push(observer);
      }
    });
    updateDimensions();
    return () => observers.forEach((o) => o.disconnect());
  }, [isVertical, logos, gap, logoHeight]);

  // Animation loop
  useEffect(() => {
    const track = trackRef.current;
    if (!track) return;

    const seqSize = isVertical ? seqHeight : seqWidth;
    let rafId: number | null = null;
    let lastTimestamp: number | null = null;
    let offset = 0;
    let velocity = 0;

    if (seqSize > 0) {
      offset = ((offset % seqSize) + seqSize) % seqSize;
      track.style.transform = isVertical
        ? `translate3d(0, ${-offset}px, 0)`
        : `translate3d(${-offset}px, 0, 0)`;
    }

    const animate = (timestamp: number) => {
      if (lastTimestamp === null) lastTimestamp = timestamp;
      const deltaTime = Math.max(0, timestamp - lastTimestamp) / 1000;
      lastTimestamp = timestamp;

      const target = isHovered && effectiveHoverSpeed !== undefined ? effectiveHoverSpeed : targetVelocity;
      const easingFactor = 1 - Math.exp(-deltaTime / ANIMATION_CONFIG.SMOOTH_TAU);
      velocity += (target - velocity) * easingFactor;

      if (seqSize > 0) {
        let nextOffset = offset + velocity * deltaTime;
        nextOffset = ((nextOffset % seqSize) + seqSize) % seqSize;
        offset = nextOffset;
        track.style.transform = isVertical
          ? `translate3d(0, ${-offset}px, 0)`
          : `translate3d(${-offset}px, 0, 0)`;
      }
      rafId = requestAnimationFrame(animate);
    };

    rafId = requestAnimationFrame(animate);

    return () => {
      if (rafId !== null) cancelAnimationFrame(rafId);
    };
  }, [targetVelocity, seqWidth, seqHeight, isHovered, effectiveHoverSpeed, isVertical]);

  const cssVariables = useMemo(
    () => ({
      "--logoloop-gap": `${gap}px`,
      "--logoloop-logoHeight": `${logoHeight}px`,
      ...(fadeOutColor && { "--logoloop-fadeColor": fadeOutColor }),
    }),
    [gap, logoHeight, fadeOutColor]
  );

  const rootClassName = useMemo(
    () =>
      [
        "logoloop",
        isVertical ? "logoloop--vertical" : "logoloop--horizontal",
        fadeOut && "logoloop--fade",
        scaleOnHover && "logoloop--scale-hover",
        className,
      ]
        .filter(Boolean)
        .join(" "),
    [isVertical, fadeOut, scaleOnHover, className]
  );

  const handleMouseEnter = useCallback(() => {
    if (effectiveHoverSpeed !== undefined) setIsHovered(true);
  }, [effectiveHoverSpeed]);
  const handleMouseLeave = useCallback(() => {
    if (effectiveHoverSpeed !== undefined) setIsHovered(false);
  }, [effectiveHoverSpeed]);

  const renderLogoItem = useCallback((item: LogoItem, key: string) => {
    const isNodeItem = "node" in item;
    const content = isNodeItem ? (
      <span className="logoloop__node">{(item as LogoNodeItem).node}</span>
    ) : (
      <img
        src={(item as LogoImageItem).src}
        alt={(item as LogoImageItem).alt ?? ""}
        title={(item as LogoImageItem).title}
        loading="lazy"
        decoding="async"
        draggable={false}
      />
    );
    const itemContent = item.href ? (
      <a
        className="logoloop__link"
        href={item.href}
        aria-label={isNodeItem ? ((item as LogoNodeItem).title ?? "logo") : ((item as LogoImageItem).alt ?? "logo")}
        target="_blank"
        rel="noreferrer noopener"
      >
        {content}
      </a>
    ) : (
      content
    );
    return (
      <li className="logoloop__item" key={key} role="listitem">
        {itemContent}
      </li>
    );
  }, []);

  const logoLists = useMemo(
    () =>
      Array.from({ length: copyCount }, (_, copyIndex) => (
        <ul
          className="logoloop__list"
          key={`copy-${copyIndex}`}
          role="list"
          aria-hidden={copyIndex > 0}
          ref={copyIndex === 0 ? seqRef : undefined}
        >
          {logos.map((item, itemIndex) => renderLogoItem(item, `${copyIndex}-${itemIndex}`))}
        </ul>
      )),
    [copyCount, logos, renderLogoItem]
  );

  const containerStyle = useMemo(
    () => ({
      width: isVertical
        ? toCssLength(width as number | string) === "100%"
          ? undefined
          : toCssLength(width as number | string)
        : (toCssLength(width as number | string) ?? "100%"),
      ...cssVariables,
      ...style,
    }),
    [width, cssVariables, style, isVertical]
  );

  return (
    <div ref={containerRef} className={rootClassName} style={containerStyle as CSSProperties} role="region" aria-label={ariaLabel}>
      <div className="logoloop__track" ref={trackRef} onMouseEnter={handleMouseEnter} onMouseLeave={handleMouseLeave}>
        {logoLists}
      </div>
    </div>
  );
}

const LogoLoop = memo(LogoLoopInner);
LogoLoop.displayName = "LogoLoop";

export default LogoLoop;
