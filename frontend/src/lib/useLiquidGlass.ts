"use client";

import { useCallback, useRef } from "react";
import { liquidGlass, LiquidGlassOptions } from "./liquid-glass";

/**
 * A hook that returns a callback ref to automatically manage liquid-glass.
 * Works perfectly for persistent and conditionally-rendered elements.
 */
export function useLiquidGlass<T extends HTMLElement>(
  options?: LiquidGlassOptions
): (node: T | null) => void {
  const glassInstanceRef = useRef<any>(null);

  const ref = useCallback((el: T | null) => {
    if (glassInstanceRef.current) {
      glassInstanceRef.current.destroy();
      glassInstanceRef.current = null;
    }
    if (el) {
      glassInstanceRef.current = liquidGlass(el, options);
    }
  }, [options]);

  return ref;
}
