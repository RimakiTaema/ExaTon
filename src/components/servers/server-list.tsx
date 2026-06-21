"use client";
import { PlusCircleIcon } from "@phosphor-icons/react";
import { openUrl } from "@tauri-apps/plugin-opener";
import { ServerCard, type ServerData } from "@/components/server-card";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";

type Props = {
  servers: ServerData[];
  loading: boolean;
  error: string;
};

export function ServerList({ servers, loading, error }: Props) {
  return (
    <div className="p-2">
      <div className="flex items-center justify-between mb-3">
        <div className="text-xl font-semibold">Servers</div>
        <Button variant="outline" size="sm" onClick={() => openUrl("https://exaroton.com/create/")}>
          <PlusCircleIcon size={16} className="mr-1.5" />
          Add Server
        </Button>
      </div>
      {loading && (
        <div className="grid gap-3 sm:grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
          {[1, 2, 3].map((i) => (
            <Skeleton key={i} className="h-28 rounded-xl" />
          ))}
        </div>
      )}
      {error && (
        <div className="flex items-center gap-2">
          <p className="text-sm text-red-600">{error}</p>
          <Button variant="outline" size="sm" onClick={() => window.location.reload()}>
            Retry
          </Button>
        </div>
      )}
      {!loading && !error && servers.length === 0 && (
        <div className="flex flex-col items-center gap-3 py-12 text-center">
          <p className="text-sm text-muted-foreground">No servers yet.</p>
          <Button variant="default" size="sm" onClick={() => openUrl("https://exaroton.com/create/")}>
            <PlusCircleIcon size={16} className="mr-1.5" />
            Add Server on exaroton
          </Button>
        </div>
      )}
      {!loading && servers.length > 0 && (
        <div className="grid gap-3 sm:grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
          {servers.map((server) => (
            <div key={server.id} data-server-card>
              <ServerCard server={server} />
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
