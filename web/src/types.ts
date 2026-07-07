/** Events broadcast by the API on /chat/:id. */
export type ServerEvent =
  | { type: "welcome"; room: string; name: string; online: number; users: string[] }
  | { type: "join"; name: string; online: number; users: string[] }
  | { type: "leave"; name: string; online: number; users: string[] }
  | { type: "message"; id: number; name: string; text: string; at: number }
  | { type: "typing"; name: string };

export type ChatMessage =
  | { key: string; kind: "system"; text: string }
  | { key: string; kind: "user"; name: string; text: string; at: number };

export type ConnectionStatus = "conectando" | "online" | "desconectado" | "erro";
