"use client"
import { useEffect, useRef, useState } from "react";
import gsap from "gsap";
import { Button } from "@/components/ui/button";
import { openUrl } from "@tauri-apps/plugin-opener";
import Link from "next/link";
import Image from "next/image";
import { PlusIcon, UserIcon } from "@phosphor-icons/react";
import { redirect, RedirectType } from "next/navigation";

type Account = {
    name: string;
    email: string;
    credits: number;
};

export default function Home() {
    const [accounts, setAccounts] = useState<Account[]>([]);
    const cardRef = useRef<HTMLDivElement>(null);
    const contentRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        try {
            const raw = localStorage.getItem("exaton_accounts");
            if (raw) setAccounts(JSON.parse(raw));
        } catch { /* empty */ }
    }, []);

    useEffect(() => {
        const ctx = gsap.context(() => {
            gsap.from(cardRef.current, {
                opacity: 0,
                y: 20,
                scale: 0.97,
                duration: 0.4,
                ease: "power3.out",
            });
            gsap.from(contentRef.current, {
                opacity: 0,
                x: -30,
                duration: 0.35,
                delay: 0.15,
                ease: "power2.out",
            });
        });
        return () => ctx.revert();
    }, []);

    // Stagger animate account cards after they render
    useEffect(() => {
        if (accounts.length > 0) {
            gsap.from("[data-account-card]", {
                opacity: 0,
                y: 12,
                duration: 0.3,
                stagger: 0.06,
                delay: 0.25,
                ease: "power2.out",
            });
        }
    }, [accounts]);

    useEffect(() => {
        window.addEventListener('keydown', e => {
            if(e.key === 'p') {
                window.location.reload()
            }
        })
    },[])

    const handleSelect = (account: Account) => {
        localStorage.setItem("exaton_selected_account", account.email);
        redirect("/home", RedirectType.replace);
    };

    return (
        <div className="flex h-screen items-center justify-center">
            <div ref={cardRef} className="w-96 rounded-xl bg-white p-8 shadow-lg">
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
                <div ref={contentRef}>
                    {accounts.length > 0 ? (
                        <div className="flex flex-col gap-2">
                            {accounts.map((account) => (
                                <button
                                    key={account.email}
                                    data-account-card
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
                            <Link href="/login" data-account-card className="flex items-center gap-3 rounded-lg border border-dashed border-gray-300 p-3 text-left transition-colors hover:bg-gray-50 cursor-pointer">
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
                </div>
            </div>
        </div>
    );
}
