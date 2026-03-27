import { useState, useRef, useEffect } from 'react';
import { Pencil } from 'lucide-react';

interface EditableTextProps {
  value: string;
  onSave: (value: string) => void;
  className?: string;
  as?: 'h1' | 'h2' | 'h3' | 'p' | 'span';
  multiline?: boolean;
}

export default function EditableText({ value, onSave, className = '', as: Tag = 'span', multiline = false }: EditableTextProps) {
  const [editing, setEditing] = useState(false);
  const [draft, setDraft] = useState(value);
  const inputRef = useRef<HTMLInputElement | HTMLTextAreaElement>(null);

  useEffect(() => { setDraft(value); }, [value]);
  useEffect(() => { if (editing) inputRef.current?.focus(); }, [editing]);

  const commit = () => {
    setEditing(false);
    if (draft.trim() !== value) onSave(draft.trim());
  };

  if (editing) {
    const shared = {
      ref: inputRef as any,
      value: draft,
      onChange: (e: any) => setDraft(e.target.value),
      onBlur: commit,
      onKeyDown: (e: React.KeyboardEvent) => {
        if (e.key === 'Enter' && !multiline) commit();
        if (e.key === 'Escape') { setDraft(value); setEditing(false); }
      },
      className: `${className} bg-transparent border-b-2 border-accent outline-none w-full`,
    };
    return multiline
      ? <textarea {...shared} rows={3} />
      : <input {...shared} />;
  }

  return (
    <Tag
      className={`${className} group cursor-pointer inline-flex items-center gap-1.5 hover:opacity-80 transition-opacity`}
      onClick={() => setEditing(true)}
      title="Cliquez pour modifier"
    >
      {value}
      <Pencil className="w-3 h-3 opacity-0 group-hover:opacity-60 transition-opacity shrink-0" />
    </Tag>
  );
}
