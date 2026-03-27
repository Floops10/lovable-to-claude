import { useWedding } from '@/contexts/WeddingContext';
import { PROJECT_LABELS, PROJECT_LIST, type ProjectId } from '@/lib/store';
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs';

const shortLabels: Record<ProjectId, string> = {
  all: 'Tous',
  dote: 'Dote',
  civil: 'Civil',
  religieux: 'Religieux',
  'lune-de-miel': 'Lune de Miel',
};

export default function ProjectTabs({ className }: { className?: string }) {
  const { data, setActiveProject } = useWedding();
  return (
    <Tabs value={data.activeProject} onValueChange={v => setActiveProject(v as ProjectId)} className={className}>
      <TabsList className="bg-muted/60">
        <TabsTrigger value="all" className="text-xs font-ui font-semibold">Tous</TabsTrigger>
        {PROJECT_LIST.map(p => (
          <TabsTrigger key={p} value={p} className="text-xs font-ui font-semibold">{shortLabels[p]}</TabsTrigger>
        ))}
      </TabsList>
    </Tabs>
  );
}
