"use client"
import { useEffect, useState } from "react"
import { PageTransition } from "@/components/page-transition"
import { Button } from "@/components/ui/button"
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip"
import { useRouter } from "next/navigation"

type Account = {
  name: string
  email: string
  credits: number
}

export default function DebugPage() {

    const [account, setAccount] = useState<Account | null>(null)

      useEffect(() => {
        try {
          const selectedEmail = localStorage.getItem("exaton_selected_account")
          if (!selectedEmail) return
          const accounts: Account[] = JSON.parse(localStorage.getItem("exaton_accounts") ?? "[]")
          const found = accounts.find((a) => a.email === selectedEmail)
          // eslint-disable-next-line react-hooks/set-state-in-effect
          if (found) setAccount(found)
        } catch { /* empty */ }
      }, [])

    const router = useRouter()

    const dback = () => {
        router.push('/')
    }

    return (
        <PageTransition>
            <div className="flex flex-wrap flex-col h-max w-max px-2 gap-2">
                <div className="font-semibold text-xl">
                        Debug Actions
                    </div>
                <Tooltip>
                    <TooltipTrigger render={<Button className="flex" variant={"destructive"} onClick={() => window.location.reload()} />}>
                        Debug Reload
                    </TooltipTrigger>
                    <TooltipContent side="right">
                        Reload Current Pages
                    </TooltipContent>
                </Tooltip>
                <Tooltip>
                    <TooltipTrigger render={<Button className="flex" variant={"destructive"} onClick={dback} />}>
                        Debug Main Menu
                    </TooltipTrigger>
                    <TooltipContent side="right">
                        Go Back To Main Menu (Accounts Page)
                    </TooltipContent>
                </Tooltip>
            </div>
        </PageTransition>
    )
}