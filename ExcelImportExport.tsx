import { useState, useRef } from 'react';
import { useWedding } from '@/contexts/WeddingContext';
import * as XLSX from 'xlsx';
import { Download, Upload, X, FileSpreadsheet } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { toast } from 'sonner';

type DataType = 'guests' | 'vendors' | 'tasks' | 'expenses' | 'contributions';

const TEMPLATES: Record<DataType, { label: string; columns: string[] }> = {
  guests: { label: 'Invités', columns: ['Nom', 'Email', 'Téléphone', 'Côté (bride/groom/both)', 'Statut (pending/confirmed/declined)', '+1 (oui/non)', 'Notes alimentaires'] },
  vendors: { label: 'Prestataires', columns: ['Nom', 'Catégorie', 'Contact', 'Prix', 'Statut (contacted/booked/paid/cancelled)', 'Notes', 'Note /5', 'Projets (dote,civil,religieux,lune-de-miel)'] },
  tasks: { label: 'Tâches', columns: ['Titre', 'Description', 'Statut (backlog/todo/in-progress/review/done)', 'Priorité (low/medium/high/urgent)', 'Assigné à', 'Deadline', 'Catégorie', 'Projet (dote/civil/religieux/lune-de-miel)'] },
  expenses: { label: 'Dépenses', columns: ['Nom', 'Catégorie', 'Montant', 'Statut (planned/paid/cancelled)', 'Date', 'Notes', 'Projets (dote,civil,religieux,lune-de-miel)'] },
  contributions: { label: 'Contributions', columns: ['De', 'Montant', 'Date', 'Notes', 'Projet (dote/civil/religieux/lune-de-miel/all)'] },
};

function downloadTemplate(type: DataType) {
  const t = TEMPLATES[type];
  const ws = XLSX.utils.aoa_to_sheet([t.columns]);
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, t.label);
  // Set column widths
  ws['!cols'] = t.columns.map(c => ({ wch: Math.max(c.length + 5, 20) }));
  XLSX.writeFile(wb, `template_${type}.xlsx`);
  toast.success(`Template ${t.label} téléchargé !`);
}

export default function ExcelImportExport({ type, onClose }: { type: DataType; onClose: () => void }) {
  const { addGuest, addVendor, addTask, addExpense, addContribution } = useWedding();
  const [importing, setImporting] = useState(false);
  const fileRef = useRef<HTMLInputElement>(null);

  const handleFile = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setImporting(true);

    try {
      const buf = await file.arrayBuffer();
      const wb = XLSX.read(buf);
      const ws = wb.Sheets[wb.SheetNames[0]];
      const rows: any[][] = XLSX.utils.sheet_to_json(ws, { header: 1 });

      if (rows.length < 2) { toast.error('Le fichier est vide'); setImporting(false); return; }

      const data = rows.slice(1).filter(r => r.some(c => c != null && c !== ''));
      let count = 0;

      for (const row of data) {
        try {
          switch (type) {
            case 'guests':
              await addGuest({ name: String(row[0] || ''), email: String(row[1] || ''), phone: String(row[2] || ''), side: (row[3] || 'both') as any, status: (row[4] || 'pending') as any, plusOne: String(row[5]).toLowerCase() === 'oui', dietaryNotes: String(row[6] || '') });
              break;
            case 'vendors':
              await addVendor({ name: String(row[0] || ''), category: String(row[1] || 'Autre'), contact: String(row[2] || ''), price: Number(row[3]) || 0, status: (row[4] || 'contacted') as any, notes: String(row[5] || ''), rating: Number(row[6]) || 0, projects: row[7] ? String(row[7]).split(',').map((s: string) => s.trim()) as any : ['religieux'] });
              break;
            case 'tasks':
              await addTask({ title: String(row[0] || ''), description: String(row[1] || ''), status: (row[2] || 'backlog') as any, priority: (row[3] || 'medium') as any, assignee: String(row[4] || ''), deadline: String(row[5] || ''), category: String(row[6] || ''), project: (row[7] || 'religieux') as any });
              break;
            case 'expenses':
              await addExpense({ name: String(row[0] || ''), category: String(row[1] || 'Autre'), amount: Number(row[2]) || 0, status: (row[3] || 'planned') as any, date: String(row[4] || ''), notes: String(row[5] || ''), projects: row[6] ? String(row[6]).split(',').map((s: string) => s.trim()) as any : ['religieux'] });
              break;
            case 'contributions':
              await addContribution({ from: String(row[0] || ''), amount: Number(row[1]) || 0, date: String(row[2] || ''), notes: String(row[3] || ''), project: (row[4] || 'all') as any });
              break;
          }
          count++;
        } catch (err) { console.error('Row import error:', err); }
      }

      toast.success(`${count} ${TEMPLATES[type].label.toLowerCase()} importé(e)s !`);
      onClose();
    } catch (err) {
      toast.error('Erreur lors de l\'import');
      console.error(err);
    }
    setImporting(false);
  };

  return (
    <motion.div initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }}
      className="bg-card border border-border rounded-xl p-5 shadow-card">
      <div className="flex items-center justify-between mb-4">
        <h3 className="font-title font-semibold flex items-center gap-2">
          <FileSpreadsheet className="w-5 h-5 text-accent" />
          Import / Export — {TEMPLATES[type].label}
        </h3>
        <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-muted"><X className="w-4 h-4" /></button>
      </div>

      <div className="flex flex-col sm:flex-row gap-3">
        <button onClick={() => downloadTemplate(type)} className="flex-1 flex items-center justify-center gap-2 px-4 py-3 rounded-lg bg-muted hover:bg-muted/80 text-sm font-ui font-medium transition-colors">
          <Download className="w-4 h-4 text-secondary" />
          Télécharger le template
        </button>

        <button onClick={() => fileRef.current?.click()} disabled={importing}
          className="flex-1 flex items-center justify-center gap-2 px-4 py-3 rounded-lg gradient-orange text-accent-foreground text-sm font-ui font-medium disabled:opacity-50">
          <Upload className="w-4 h-4" />
          {importing ? 'Import en cours...' : 'Importer un fichier'}
        </button>
        <input ref={fileRef} type="file" accept=".xlsx,.xls,.csv" onChange={handleFile} className="hidden" />
      </div>

      <p className="text-xs text-muted-foreground font-ui mt-3">
        Téléchargez d'abord le template, remplissez-le, puis importez-le. Formats : .xlsx, .xls, .csv
      </p>
    </motion.div>
  );
}
