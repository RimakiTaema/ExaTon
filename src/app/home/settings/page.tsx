import { SidebarSeparator } from "@/components/ui/sidebar";
import { GearIcon } from "@phosphor-icons/react/dist/ssr";

export default function SettingPage() {
    return (
        <>
        <div className="flex flex-col p-2 gap-1">
            <div className="flex">
                <div className="flex items-center gap-2 text-2xl font-bold">
                    <GearIcon />
                    <span>Settings</span>
                </div>
            </div>
            <SidebarSeparator />
            <div className="text-xs text-gray-400">
                Settings -- Soon..
            </div>
        </div>
        </>
    )
}