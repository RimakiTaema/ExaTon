"use client";
import { useEffect, useState } from "react";

export type Account = {
  name: string;
  email: string;
  credits: number;
};

export function useAccount(): Account | null {
  const [account, setAccount] = useState<Account | null>(null);

  useEffect(() => {
    try {
      const selectedEmail = localStorage.getItem("exaton_selected_account");
      if (!selectedEmail) return;
      const accounts: Account[] = JSON.parse(localStorage.getItem("exaton_accounts") ?? "[]");
      const found = accounts.find((a) => a.email === selectedEmail);
      if (found) setAccount(found);
    } catch {
      /* empty */
    }
  }, []);

  return account;
}
