import { useChat } from "../hooks/useChat";
import type { ConnectionStatus } from "../types";
import { MessageInput } from "./MessageInput";
import { MessageList } from "./MessageList";
import { TypingIndicator } from "./TypingIndicator";

interface Props {
  room: string;
  onLeave: () => void;
}

const STATUS_COLOR: Record<ConnectionStatus, string> = {
  conectando: "text-slate-400",
  online: "text-green-400",
  desconectado: "text-red-400",
  erro: "text-red-400",
};

export function ChatRoom({ room, onLeave }: Props) {
  const { status, me, online, messages, typers, sendMessage, sendTyping } = useChat(room);

  return (
    <div className="flex h-full flex-col gap-2 p-3">
      <header className="flex items-center justify-between border-b border-slate-800 px-1 py-2">
        <div className="flex items-center gap-2">
          <strong>#{room}</strong>
          <span className={`text-xs ${STATUS_COLOR[status]}`}>{status}</span>
        </div>
        <div className="flex items-center gap-3">
          {me && <span className="text-sm text-blue-300">{me}</span>}
          <span className="text-sm text-slate-400">{online} online</span>
          <button
            className="rounded-lg bg-slate-800 px-3 py-1.5 text-sm hover:bg-slate-700"
            onClick={onLeave}
          >
            Sair
          </button>
        </div>
      </header>

      <MessageList messages={messages} me={me} />
      <TypingIndicator typers={typers} />
      <MessageInput onSend={sendMessage} onTyping={sendTyping} />
    </div>
  );
}
