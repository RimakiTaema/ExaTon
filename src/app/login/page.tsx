"use client"

import { useRef, useEffect, useState } from "react";
import { invoke } from "@tauri-apps/api/core";
import { useRouter } from "next/navigation";
import gsap from "gsap";
import { Input } from "@/components/ui/input";
import { Field, FieldSet, FieldLabel, FieldDescription, FieldGroup } from "@/components/ui/field";
import { Button } from "@/components/ui/button";
import { ArrowLeftIcon } from "@phosphor-icons/react";
import Link from "next/link";
import Image from "next/image";

export default function LoginPage() {
    const router = useRouter();
    const [token, setToken] = useState("");
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(false);
    const cardRef = useRef<HTMLDivElement>(null);
    const formRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        const ctx = gsap.context(() => {
            gsap.from(cardRef.current, {
                opacity: 0,
                y: 20,
                scale: 0.97,
                duration: 0.4,
                ease: "power3.out",
            });
            gsap.from(formRef.current, {
                opacity: 0,
                x: 30,
                duration: 0.35,
                delay: 0.15,
                ease: "power2.out",
            });
        });
        return () => ctx.revert();
    }, []);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!token.trim()) return;

        setLoading(true);
        setError("");

        try {
            const result = await invoke<{ success: boolean; data: { name: string; email: string; credits: number } | null }>("get_acc_info", { token });
            if (result.success && result.data) {
                await invoke("save_token", { email: result.data.email, token });

                const accounts = JSON.parse(localStorage.getItem("exaton_accounts") ?? "[]");
                const account = { name: result.data.name, email: result.data.email, credits: result.data.credits };
                const idx = accounts.findIndex((a: { email: string }) => a.email === account.email);
                if (idx >= 0) {
                    accounts[idx] = account;
                } else {
                    accounts.push(account);
                }
                localStorage.setItem("exaton_accounts", JSON.stringify(accounts));

                // Animate out before navigating
                gsap.to(cardRef.current, {
                    opacity: 0,
                    y: -15,
                    scale: 0.97,
                    duration: 0.25,
                    ease: "power2.in",
                    onComplete: () => router.push("/"),
                });
            } else {
                setError("Invalid token or account not found.");
            }
        } catch (err) {
            setError(String(err));
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="flex h-screen items-center justify-center">
            <div ref={cardRef} className="w-96 rounded-xl bg-white p-8 shadow-lg">
                <Link href="/">
                    <ArrowLeftIcon size={20} className="cursor-pointer text-gray-500 hover:text-gray-900" />
                </Link>
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
                <div ref={formRef}>
                    <form onSubmit={handleSubmit}>
                        <FieldSet>
                            <FieldGroup>
                                <Field>
                                    <FieldLabel htmlFor="token">API token</FieldLabel>
                                    <Input
                                        id="token"
                                        type="password"
                                        placeholder="A1b2C3d........"
                                        value={token}
                                        onChange={(e) => setToken(e.target.value)}
                                    />
                                    <FieldDescription>
                                        Required to access exaroton services.{" "}
                                        <a href="https://exaroton.com/account/settings" className="underline text-emerald-700 cursor-pointer" target="_blank" rel="noopener noreferrer">
                                            Get your token here
                                        </a>
                                    </FieldDescription>
                                </Field>
                                {error && (
                                    <p className="text-sm text-red-600">{error}</p>
                                )}
                                <Field orientation="horizontal">
                                    <Button type="submit" className="cursor-pointer" disabled={loading}>
                                        {loading ? "Logging in..." : "Login"}
                                    </Button>
                                </Field>
                            </FieldGroup>
                        </FieldSet>
                    </form>
                </div>
           </div>
        </div>
    )
}
