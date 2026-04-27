"use client";
import type { ReactNode } from "react";
import { Button } from "@/components/ui/button";
import { useApiProbe } from "@/hooks/use-api-probe";

export function ConnectionGate({ children }: { children: ReactNode }) {
  const { status, error, retry } = useApiProbe();

  if (status === "online") return <>{children}</>;

  return (
    <div className="flex h-screen items-center justify-center">
      <div className="w-96 rounded-xl bg-white p-8 shadow-lg text-center">
        {status === "checking" && (
          <>
            <p className="text-lg font-semibold text-gray-900">Checking connection…</p>
            <p className="mt-2 text-sm text-gray-500">Verifying exaroton API reachability.</p>
          </>
        )}
        {status === "offline" && (
          <>
            <p className="text-lg font-semibold text-gray-900">You&apos;re offline</p>
            <p className="mt-2 text-sm text-gray-500">
              ExaTon needs an internet connection to reach the exaroton API.
            </p>
            <Button className="mt-4 cursor-pointer" onClick={retry}>
              Retry
            </Button>
          </>
        )}
        {status === "broken" && (
          <>
            <p className="text-lg font-semibold text-gray-900">API error</p>
            <p className="mt-2 break-words text-sm text-gray-500">{error}</p>
            <Button className="mt-4 cursor-pointer" onClick={retry}>
              Retry
            </Button>
          </>
        )}
      </div>
    </div>
  );
}
