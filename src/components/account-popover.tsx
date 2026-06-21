"use client";

import { ArrowSquareOutIcon, ArrowsClockwiseIcon, DoorOpenIcon, UserIcon } from "@phosphor-icons/react";
import type { CachedAccountSummary } from "@/lib/account-summary";
import { formatAgo } from "@/lib/account-summary";
import type { CreditDisplay } from "@/lib/display-prefs";
import { Button } from "./ui/button";

type Account = {
  name: string;
  email: string;
  credits: number;
};

export function AccountInfoCard({
  account,
  summary,
  displayMode,
  onProfile,
}: {
  account: Account;
  summary: CachedAccountSummary | null;
  displayMode: CreditDisplay;
  onProfile?: (e: React.MouseEvent) => void;
}) {
  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-center gap-3">
        <div className="flex size-10 shrink-0 items-center justify-center rounded-full bg-emerald-100 text-emerald-700">
          <UserIcon size={20} />
        </div>
        <div className="min-w-0">
          <p className="text-sm font-semibold text-gray-900 truncate dark:text-gray-100">
            {account.name}
          </p>
          <p className="text-xs text-gray-500 truncate dark:text-gray-400">{account.email}</p>
        </div>
      </div>
      <div className="rounded-md bg-emerald-50 px-3 py-2 dark:bg-emerald-900/20">
        <p className="text-xs text-emerald-600 font-medium dark:text-emerald-400">Credits</p>
        {displayMode === "personal" && (
          <p className="text-lg font-bold text-emerald-700 dark:text-emerald-300">
            {(summary?.personalCredits ?? account.credits).toFixed(2)} cr
          </p>
        )}
        {displayMode === "pool" && (
          <p className="text-lg font-bold text-emerald-700 dark:text-emerald-300">
            {summary
              ? summary.poolCredits === 0
                ? "—"
                : `${summary.poolCredits.toFixed(2)} pool`
              : "—"}
          </p>
        )}
        {displayMode === "both" && (
          <>
            <p className="text-lg font-bold text-emerald-700 dark:text-emerald-300">
              {(summary?.personalCredits ?? account.credits).toFixed(2)} cr
            </p>
            {summary && summary.poolCredits > 0 && (
              <p className="text-xs text-emerald-700/80 dark:text-emerald-300/80">
                + {summary.poolCredits.toFixed(2)} pool
              </p>
            )}
            {summary && summary.poolCredits === 0 && (
              <p className="text-xs text-emerald-700/80 dark:text-emerald-300/80">
                + — pool
              </p>
            )}
          </>
        )}
        {summary && (
          <p className="mt-1 text-[10px] text-emerald-700/60 dark:text-emerald-300/60">
            updated {formatAgo(summary.updatedAt)}
          </p>
        )}
      </div>
      {summary && (
        <div className="rounded-md bg-gray-50 px-3 py-2 dark:bg-gray-800">
          <p className="mb-1 text-xs font-medium text-gray-600 dark:text-gray-400">Pools</p>
          {summary.pools.length > 0 ? (
            <div className="flex flex-col gap-1">
              {summary.pools.map((p) => (
                <div
                  key={p.id}
                  className="flex items-center justify-between gap-2 text-xs"
                >
                  <span className="truncate text-gray-900 dark:text-gray-200">
                    {p.name}
                    {p.isOwner && (
                      <span className="ml-1 text-[10px] text-emerald-600 dark:text-emerald-400">
                        (owner)
                      </span>
                    )}
                  </span>
                  <span className="text-gray-500 dark:text-gray-400">
                    {p.ownCredits.toFixed(2)}
                    <span className="text-gray-400">
                      {" "}/ {p.totalCredits.toFixed(2)}
                    </span>
                  </span>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-xs text-gray-500 italic dark:text-gray-400">
              Pool not available (can't see due to permission)
            </p>
          )}
        </div>
      )}
      {onProfile && (
        <Button
          variant="outline"
          size="sm"
          className="w-full cursor-pointer"
          onClick={onProfile}
        >
          <UserIcon size={14} />
          Profile Settings
        </Button>
      )}
    </div>
  );
}

export function AccountActions({
  account,
  refreshing,
  onRefresh,
  onDashboard,
  onGoBack,
  variant = "inline",
}: {
  account: Account;
  refreshing: boolean;
  onRefresh: (e: React.MouseEvent) => void;
  onDashboard: (e: React.MouseEvent) => void;
  onGoBack: (e: React.MouseEvent) => void;
  variant?: "inline" | "popover";
}) {
  if (variant === "popover") {
    return (
      <div className="flex flex-col gap-1">
        <Button variant="outline" size="sm" className="w-full cursor-pointer" onClick={onRefresh} disabled={refreshing}>
          <ArrowsClockwiseIcon size={14} className={refreshing ? "animate-spin" : ""} />
          Refresh
        </Button>
        <Button variant="outline" size="sm" className="w-full cursor-pointer" onClick={onDashboard}>
          <ArrowSquareOutIcon size={14} />
          Dashboard
        </Button>
        <Button variant="outline" size="sm" className="w-full cursor-pointer" onClick={onGoBack}>
          <DoorOpenIcon size={14} />
          Switch Account
        </Button>
      </div>
    );
  }

  return (
    <div className="flex items-center gap-1">
      <Button
        className="flex-1 cursor-pointer"
        size="sm"
        variant="outline"
        onClick={onRefresh}
        disabled={refreshing}
      >
        <ArrowsClockwiseIcon size={14} className={refreshing ? "animate-spin" : ""} />
        <span className="text-xs">Refresh</span>
      </Button>
      <Button
        className="flex-1 cursor-pointer"
        size="sm"
        variant="outline"
        onClick={onDashboard}
      >
        <ArrowSquareOutIcon size={14} />
        <span className="text-xs">Dashboard</span>
      </Button>
      <Button
        className="shrink-0 cursor-pointer"
        size="sm"
        variant="destructive"
        onClick={onGoBack}
      >
        <DoorOpenIcon size={14} />
      </Button>
    </div>
  );
}
