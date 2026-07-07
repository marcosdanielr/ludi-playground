import { useEffect, useState } from "react";
import { API_URL } from "../config";

interface RoomInfo {
  id: string;
  online: number;
}

interface Props {
  onJoin: (room: string) => void;
}

const ROOMS_REFRESH_MS = 5000;

export function JoinScreen({ onJoin }: Props) {
  const [room, setRoom] = useState("");
  const [rooms, setRooms] = useState<RoomInfo[]>([]);

  useEffect(() => {
    let alive = true;

    async function load() {
      try {
        const response = await fetch(`${API_URL}/rooms`);
        const data = await response.json();
        // An empty Lua table encodes as {}, not [].
        if (alive) setRooms(Array.isArray(data.rooms) ? data.rooms : []);
      } catch {
        if (alive) setRooms([]);
      }
    }

    load();
    const timer = setInterval(load, ROOMS_REFRESH_MS);
    return () => {
      alive = false;
      clearInterval(timer);
    };
  }, []);

  return (
    <div className="m-auto flex w-full max-w-sm flex-col gap-4 p-4 text-center">
      <h1 className="text-3xl font-bold">Ludi Chat</h1>
      <p className="text-sm text-slate-400">
        Entre numa sala existente ou digite um nome para criar uma nova. Seu
        apelido é sorteado pelo servidor.
      </p>

      <form
        className="flex gap-2"
        onSubmit={(e) => {
          e.preventDefault();
          if (room.trim()) onJoin(room.trim());
        }}
      >
        <input
          className="min-w-0 flex-1 rounded-lg border border-slate-700 bg-slate-900 px-3 py-2 outline-none focus:border-blue-500"
          value={room}
          onChange={(e) => setRoom(e.target.value)}
          placeholder="nome da sala"
          autoFocus
        />
        <button
          className="rounded-lg bg-blue-600 px-4 py-2 hover:bg-blue-500"
          type="submit"
        >
          Entrar
        </button>
      </form>

      {rooms.length > 0 && (
        <div className="flex flex-col gap-2 text-left">
          <span className="text-xs tracking-wide text-slate-500 uppercase">
            Salas ativas
          </span>
          {rooms.map((r) => (
            <button
              key={r.id}
              className="flex items-center justify-between rounded-lg border border-slate-800 bg-slate-900 px-3 py-2 hover:border-blue-500"
              onClick={() => onJoin(r.id)}
            >
              <span>#{r.id}</span>
              <span className="text-xs text-slate-400">{r.online} online</span>
            </button>
          ))}
        </div>
      )}
      {rooms.length === 0 && (
        <p className="text-xs text-slate-500">Nenhuma sala ativa agora.</p>
      )}
    </div>
  );
}
