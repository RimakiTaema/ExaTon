"use client"
import { Button } from "@/components/ui/button"
import { useRouter } from "next/navigation"

export default function DebugPage() {

    const router = useRouter()

    const dback = () => {
        router.push('/')
    }

    return (
        <div className="flex flex-col h-max w-max px-2 gap-2">
            <Button variant={"destructive"} onClick={() => window.location.reload()}>Debug Reload</Button>
            <Button variant={"destructive"} onClick={dback}>Debug Go back</Button>
        </div>
    )
}