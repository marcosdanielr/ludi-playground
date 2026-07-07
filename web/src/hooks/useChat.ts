import { useCallback, useEffect, useRef, useState } from "react";
import { WS_URL } from "../config";
import type { ChatMessage, ConnectionStatus, ServerEvent } from "../types";

const MAX_MESSAGES = 20;
const TYPING_TTL_MS = 2500;
const TYPING_THROTTLE_MS = 1000;

let localId = 0;

export interface Chat {
  status: ConnectionStatus;
  me: string | null;
  online: number;
  messages: ChatMessage[];
  typers: string[];
  sendMessage: (text: string) => void;
  sendTyping: () => void;
}

export function useChat(room: string): Chat {
  const [status, setStatus] = useState<ConnectionStatus>("conectando");
  const [me, setMe] = useState<string | null>(null);
  const [online, setOnline] = useState(0);
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [typers, setTypers] = useState<string[]>([]);

  const wsRef = useRef<WebSocket | null>(null);
  const typingTimers = useRef<Record<string, number>>({});
  const lastTypingSent = useRef(0);

  const pushMessage = (msg: ChatMessage) =>
    setMessages((prev) => [...prev, msg].slice(-MAX_MESSAGES));

  const clearTyper = useCallback((name: string) => {
    clearTimeout(typingTimers.current[name]);
    delete typingTimers.current[name];
    setTypers((prev) => prev.filter((n) => n !== name));
  }, []);

  const markTyper = useCallback(
    (name: string) => {
      clearTimeout(typingTimers.current[name]);
      typingTimers.current[name] = window.setTimeout(() => clearTyper(name), TYPING_TTL_MS);
      setTypers((prev) => (prev.includes(name) ? prev : [...prev, name]));
    },
    [clearTyper]
  );

  useEffect(() => {
    const ws = new WebSocket(`${WS_URL}/chat/${encodeURIComponent(room)}`);
    wsRef.current = ws;

    ws.onopen = () => setStatus("online");
    ws.onclose = () => setStatus("desconectado");
    ws.onerror = () => setStatus("erro");

    ws.onmessage = (event: MessageEvent<string>) => {
      const msg = JSON.parse(event.data) as ServerEvent;

      switch (msg.type) {
        case "welcome":
          setMe(msg.name);
          setOnline(msg.online);
          break;
        case "join":
        case "leave":
          setOnline(msg.online);
          pushMessage({
            key: `local-${localId++}`,
            kind: "system",
            text: `${msg.name} ${msg.type === "join" ? "entrou" : "saiu"}`,
          });
          break;
        case "message":
          clearTyper(msg.name);
          pushMessage({
            key: `srv-${msg.id}`,
            kind: "user",
            name: msg.name,
            text: msg.text,
            at: msg.at,
          });
          break;
        case "typing":
          markTyper(msg.name);
          break;
      }
    };

    const timers = typingTimers.current;
    return () => {
      Object.values(timers).forEach(clearTimeout);
      typingTimers.current = {};
      ws.close();
    };
  }, [room, clearTyper, markTyper]);

  const sendMessage = useCallback((text: string) => {
    const trimmed = text.trim();
    if (!trimmed || wsRef.current?.readyState !== WebSocket.OPEN) return;
    wsRef.current.send(JSON.stringify({ type: "message", text: trimmed }));
  }, []);

  const sendTyping = useCallback(() => {
    const now = Date.now();
    if (now - lastTypingSent.current < TYPING_THROTTLE_MS) return;
    lastTypingSent.current = now;
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify({ type: "typing" }));
    }
  }, []);

  return { status, me, online, messages, typers, sendMessage, sendTyping };
}
