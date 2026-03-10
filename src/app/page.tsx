"use client"
import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { openUrl } from "@tauri-apps/plugin-opener";
import Link from "next/link";
import { motion } from "motion/react";
import Image from "next/image";
import { PlusIcon, UserIcon } from "@phosphor-icons/react";

type Account = {
    name: string;
    email: string;
    credits: number;
};

export default function Home() {
    const [accounts, setAccounts] = useState<Account[]>([]);

    useEffect(() => {
        try {
            const raw = localStorage.getItem("exaton_accounts");
            if (raw) setAccounts(JSON.parse(raw));
        } catch { /* empty */ }
    }, []);

    const handleSelect = (account: Account) => {
        localStorage.setItem("exaton_selected_account", account.email);
        // TODO: navigate to dashboard
    };

    return (
        <div className="flex h-screen items-center justify-center">
            <div className="w-96 rounded-xl bg-white p-8 shadow-lg">
                <div className="flex flex-col items-center justify-center">
                    <Image src="/66498436.png" alt="Exaroton Logo" width={50} height={50} />
                </div>
                <div className="text-center text-2xl leading-tight tracking-tight text-gray-900 font-semibold">
                    ExaTon
                    <p className="text-lg leading-tight tracking-tight text-emerald-700 text-shadow-2xs text-shadow-emerald-300">
                        NEXT
                    </p>
                </div>
                <br/>
                <motion.div
                    initial={{ opacity: 0, x: -30 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ duration: 0.25, ease: "easeOut" }}
                >
                    {accounts.length > 0 ? (
                        <div className="flex flex-col gap-2">
                            {accounts.map((account) => (
                                <button
                                    key={account.email}
                                    onClick={() => handleSelect(account)}
                                    className="flex items-center gap-3 rounded-lg border border-gray-200 p-3 text-left transition-colors hover:bg-gray-50 cursor-pointer"
                                >
                                    <div className="flex h-9 w-9 items-center justify-center rounded-full bg-emerald-100 text-emerald-700">
                                        <UserIcon size={18} />
                                    </div>
                                    <div className="flex-1 min-w-0">
                                        <p className="text-sm font-medium text-gray-900 truncate">{account.name}</p>
                                        <p className="text-xs text-gray-500 truncate">{account.email}</p>
                                    </div>
                                    <p className="text-xs text-emerald-700 font-medium">{account.credits.toFixed(2)} cr</p>
                                </button>
                            ))}
                            <Link href="/login" className="flex items-center gap-3 rounded-lg border border-dashed border-gray-300 p-3 text-left transition-colors hover:bg-gray-50 cursor-pointer">
                                <div className="flex h-9 w-9 items-center justify-center rounded-full bg-gray-100 text-gray-500">
                                    <PlusIcon size={18} />
                                </div>
                                <p className="text-sm text-gray-500">Add another account</p>
                            </Link>
                        </div>
                    ) : (
                        <div className="flex content-center items-center justify-center gap-2">
                            <Button>
                                <Link href="/login">Login</Link>
                            </Button>
                            <Button className="cursor-pointer" onClick={() => openUrl("https://exaroton.com/signup")}>
                                Register
                            </Button>
                        </div>
                    )}
                </motion.div>
            </div>
        </div>
    );
}
