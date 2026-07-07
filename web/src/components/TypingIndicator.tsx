interface Props {
  typers: string[];
}

export function TypingIndicator({ typers }: Props) {
  return (
    <div className="min-h-5 px-1 text-xs text-slate-400 italic">
      {typers.length === 1 && `${typers[0]} está digitando…`}
      {typers.length > 1 && `${typers.join(", ")} estão digitando…`}
    </div>
  );
}
