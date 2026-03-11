"use client"

import { PageTransition } from "@/components/page-transition"
import { Separator } from "@/components/ui/separator"
import { useState, useEffect } from "react"

type Account = {
  name: string
  email: string
  credits: number
}

export default function HomePage() {

    const [account, setAccount] = useState<Account | null>(null)
    
      useEffect(() => {
        try {
          const selectedEmail = localStorage.getItem("exaton_selected_account")
          if (!selectedEmail) return
          const accounts: Account[] = JSON.parse(localStorage.getItem("exaton_accounts") ?? "[]")
          const found = accounts.find((a) => a.email === selectedEmail)
          if (found) setAccount(found)
        } catch { /* empty */ }
      }, [])

    return (
        <PageTransition>
            <div className="flex flex-col h-max w-max px-2">
                <div className="text-2xl font-bold">
                    Welcome Back {account?.name}!
                </div>
                <br />
                <div className="text-xl font-semibold">
                    Servers
                </div>
                <br />
                <div>

                </div>
            </div>
        </PageTransition>
    )
}