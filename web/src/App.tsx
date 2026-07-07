import { useState } from "react";
import { ChatRoom } from "./components/ChatRoom";
import { JoinScreen } from "./components/JoinScreen";

export default function App() {
  const [room, setRoom] = useState<string | null>(null);

  return (
    <div className="mx-auto flex h-dvh max-w-2xl flex-col">
      {room ? (
        <ChatRoom room={room} onLeave={() => setRoom(null)} />
      ) : (
        <JoinScreen onJoin={setRoom} />
      )}
    </div>
  );
}
