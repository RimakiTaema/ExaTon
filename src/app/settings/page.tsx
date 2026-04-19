"use client";
import { ArrowArcLeftIcon } from "@phosphor-icons/react";
import Link from "next/link";
import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { type CreditDisplay, loadCreditDisplay, saveCreditDisplay } from "@/lib/display-prefs";

const OPTIONS: { value: CreditDisplay; label: string; hint: string }[] = [
  { value: "personal", label: "Personal", hint: "Only your own account balance." },
  { value: "pool", label: "Pool", hint: "Only your share of credit pools." },
  { value: "both", label: "Both", hint: "Personal balance with pool share beside it." },
];

export default function SettingsPage() {
  const [mode, setMode] = useState<CreditDisplay>("both");

  useEffect(() => {
    setMode(loadCreditDisplay());
  }, []);

  const choose = (next: CreditDisplay) => {
    setMode(next);
    saveCreditDisplay(next);
  };

  return (
    <div className="flex h-screen items-center justify-center">
      <div className="w-96 rounded-xl bg-white p-8 shadow-lg">
        <div className="mb-4 flex items-center gap-2">
          <Link href="/">
            <Button variant="outline" size="sm">
              <ArrowArcLeftIcon size={14} /> Back
            </Button>
          </Link>
          <h1 className="text-lg font-semibold text-gray-900">Settings</h1>
        </div>

        <div className="flex flex-col gap-3">
          <div>
            <p className="text-sm font-medium text-gray-900">Credit display</p>
            <p className="text-xs text-gray-500">
              What to show on each account card on the main page.
            </p>
          </div>
          <div className="flex flex-col gap-2">
            {OPTIONS.map((opt) => {
              const active = mode === opt.value;
              return (
                <button
                  type="button"
                  key={opt.value}
                  onClick={() => choose(opt.value)}
                  className={`flex flex-col gap-0.5 rounded-lg border p-3 text-left transition-colors ${
                    active ? "border-emerald-500 bg-emerald-50" : "border-gray-200 hover:bg-gray-50"
                  }`}
                >
                  <span className="text-sm font-medium text-gray-900">{opt.label}</span>
                  <span className="text-xs text-gray-500">{opt.hint}</span>
                </button>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}
