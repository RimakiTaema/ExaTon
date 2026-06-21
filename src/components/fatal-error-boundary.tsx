"use client";

import { WarningCircleIcon } from "@phosphor-icons/react";
import { Component } from "react";

type Props = {
  children: React.ReactNode;
};

type State = {
  hasError: boolean;
};

export class FatalErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(): State {
    return { hasError: true };
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    console.error("[FatalErrorBoundary]", error, info.componentStack);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="flex h-screen items-center justify-center bg-background">
          <div className="w-96 rounded-xl bg-card p-8 shadow-lg text-center">
            <WarningCircleIcon
              size={48}
              className="mx-auto text-destructive"
            />
            <p className="mt-4 text-lg font-semibold text-foreground">
              Something went wrong
            </p>
            <p className="mt-2 text-sm text-muted-foreground">
              An unexpected error occurred.
            </p>
            <button
              type="button"
              onClick={() => window.location.reload()}
              className="mt-6 inline-flex items-center justify-center rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 transition-colors cursor-pointer"
            >
              Reload
            </button>
          </div>
        </div>
      );
    }
    return this.props.children;
  }
}
