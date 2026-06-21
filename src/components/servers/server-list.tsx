"use client";
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
      <div className="text-xl font-semibold mb-3">Servers</div>
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
        <p className="text-sm text-muted-foreground">No servers found.</p>
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
