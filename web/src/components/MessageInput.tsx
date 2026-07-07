import { useState } from "react";

interface Props {
  onSend: (text: string) => void;
  onTyping: () => void;
}

export function MessageInput({ onSend, onTyping }: Props) {
  const [text, setText] = useState("");

  return (
    <form
      className="flex gap-2"
      onSubmit={(e) => {
        e.preventDefault();
        if (!text.trim()) return;
        onSend(text);
        setText("");
      }}
    >
      <input
        className="min-w-0 flex-1 rounded-lg border border-slate-700 bg-slate-900 px-3 py-2 outline-none focus:border-blue-500"
        value={text}
        onChange={(e) => {
          setText(e.target.value);
          onTyping();
        }}
        placeholder="Mensagem"
        autoFocus
      />
      <button className="rounded-lg bg-blue-600 px-4 py-2 hover:bg-blue-500" type="submit">
        Enviar
      </button>
    </form>
  );
}
