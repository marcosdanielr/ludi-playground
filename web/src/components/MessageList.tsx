import { useEffect, useRef } from "react";
import type { ChatMessage } from "../types";

interface Props {
  messages: ChatMessage[];
  me: string | null;
}

export function MessageList({ messages, me }: Props) {
  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  return (
    <main className="flex flex-1 flex-col gap-1.5 overflow-y-auto px-1 py-2">
      {messages.map((msg) =>
        msg.kind === "system" ? (
          <div key={msg.key} className="text-center text-xs text-slate-500">
            {msg.text}
          </div>
        ) : (
          <div
            key={msg.key}
            className={`flex max-w-[75%] flex-col gap-0.5 rounded-xl px-3 py-2 ${
              msg.name === me ? "self-end bg-blue-950" : "self-start bg-slate-900"
            }`}
          >
            <span className="text-xs text-blue-300">{msg.name}</span>
            <span className="[overflow-wrap:anywhere]">{msg.text}</span>
          </div>
        )
      )}
      <div ref={bottomRef} />
    </main>
  );
}
