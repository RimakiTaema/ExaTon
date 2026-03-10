"use client"

import { useRef, useEffect } from "react"
import gsap from "gsap"

export function PageTransition({ children }: { children: React.ReactNode }) {
  const ref = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!ref.current) return
    const ctx = gsap.context(() => {
      gsap.from(ref.current, {
        opacity: 0,
        y: 12,
        duration: 0.3,
        ease: "power2.out",
      })
    })
    return () => ctx.revert()
  }, [])

  return <div ref={ref}>{children}</div>
}
