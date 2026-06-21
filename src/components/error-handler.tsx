"use client";

import { CheckCircleIcon, InfoIcon, WarningCircleIcon, XIcon } from "@phosphor-icons/react";
import { createContext, useCallback, useContext, useEffect, useRef, useState } from "react";
import { Button } from "@/components/ui/button";

type ToastLevel = "error" | "success" | "info";

type ToastEntry = {
  id: number;
  message: string;
  level: ToastLevel;
  retry?: () => void;
};

type NotifierContext = {
  reportError: (message: string, retry?: () => void) => void;
  notify: (message: string, level?: "success" | "info") => void;
};

const NotifierCtx = createContext<NotifierContext | null>(null);

export function useErrorReporter() {
  const ctx = useContext(NotifierCtx);
  if (!ctx) throw new Error("useErrorReporter must be used within ErrorReporterProvider");
  return ctx;
}

function toastStyle(level: ToastLevel) {
  switch (level) {
    case "error":
      return "bg-destructive text-destructive-foreground";
    case "success":
      return "bg-emerald-600 text-white";
    case "info":
      return "bg-foreground/90 text-background";
  }
}

function toastIcon(level: ToastLevel, size: number) {
  switch (level) {
    case "error":
      return <WarningCircleIcon size={size} className="shrink-0 mt-0.5" />;
    case "success":
      return <CheckCircleIcon size={size} className="shrink-0 mt-0.5" />;
    case "info":
      return <InfoIcon size={size} className="shrink-0 mt-0.5" />;
  }
}

export function ErrorReporterProvider({ children }: { children: React.ReactNode }) {
  const [toasts, setToasts] = useState<ToastEntry[]>([]);
  const [selected, setSelected] = useState<ToastEntry | null>(null);
  const nextId = useRef(0);

  const reportError = useCallback((message: string, retry?: () => void) => {
    const entry: ToastEntry = { id: nextId.current++, message, level: "error", retry };
    setToasts((prev) => [...prev, entry]);
  }, []);

  const notify = useCallback((message: string, level: "success" | "info" = "success") => {
    const entry: ToastEntry = { id: nextId.current++, message, level };
    setToasts((prev) => [...prev, entry]);
  }, []);

  const dismissToast = useCallback((id: number) => {
    setToasts((prev) => prev.filter((e) => e.id !== id));
  }, []);

  const dismissModal = useCallback(() => {
    setSelected(null);
  }, []);

  // Auto-dismiss toasts: 6s for errors, 3s for success/info
  useEffect(() => {
    if (toasts.length === 0) return;
    const first = toasts[0];
    const delay = first.level === "error" ? 6000 : 3000;
    const id = setTimeout(() => {
      setToasts((prev) => prev.slice(1));
    }, delay);
    return () => clearTimeout(id);
  }, [toasts]);

  // Global error handlers for uncaught exceptions outside React
  useEffect(() => {
    const onError = (event: ErrorEvent) => {
      reportError(event.message || "A fatal error occurred");
    };
    const onRejection = (event: PromiseRejectionEvent) => {
      const msg = event.reason?.message || event.reason || "An unexpected error occurred";
      reportError(typeof msg === "string" ? msg : String(msg));
    };
    window.addEventListener("error", onError);
    window.addEventListener("unhandledrejection", onRejection);
    return () => {
      window.removeEventListener("error", onError);
      window.removeEventListener("unhandledrejection", onRejection);
    };
  }, [reportError]);

  return (
    <NotifierCtx.Provider value={{ reportError, notify }}>
      {children}
      {toasts.length > 0 && (
        <div className="fixed bottom-4 right-4 z-[100] flex flex-col gap-2 max-w-sm">
          {toasts.map((t) => (
            <button
              key={t.id}
              type="button"
              onClick={() => (t.level === "error" ? setSelected(t) : dismissToast(t.id))}
              className={`flex items-start gap-3 rounded-lg px-4 py-3 text-sm shadow-lg ring-1 ring-foreground/10 cursor-pointer text-left animate-in slide-in-from-right-2 fade-in ${toastStyle(t.level)}`}
            >
              {toastIcon(t.level, 18)}
              <span className="flex-1 break-words">{t.message}</span>
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation();
                  dismissToast(t.id);
                }}
                className="shrink-0 opacity-60 hover:opacity-100 cursor-pointer"
              >
                <XIcon size={14} />
              </button>
            </button>
          ))}
        </div>
      )}
      {selected && (
        <div
          className="fixed inset-0 z-[110] flex items-center justify-center bg-black/40"
          onClick={dismissModal}
        >
          <div
            className="w-96 rounded-xl bg-popover p-6 shadow-xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-start gap-3">
              <WarningCircleIcon size={22} className="shrink-0 text-destructive mt-0.5" />
              <div className="flex-1 min-w-0">
                <p className="text-base font-semibold text-foreground">Something went wrong</p>
                <p className="mt-1 text-sm text-muted-foreground break-words">{selected.message}</p>
              </div>
            </div>
            <div className="mt-5 flex items-center gap-2 justify-end">
              <Button variant="outline" size="sm" className="cursor-pointer" onClick={dismissModal}>
                Dismiss
              </Button>
              {selected.retry && (
                <Button
                  variant="default"
                  size="sm"
                  className="cursor-pointer"
                  onClick={() => {
                    selected.retry?.();
                    dismissModal();
                    dismissToast(selected.id);
                  }}
                >
                  Try Again
                </Button>
              )}
            </div>
          </div>
        </div>
      )}
    </NotifierCtx.Provider>
  );
}
