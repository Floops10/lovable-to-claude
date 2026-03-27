import { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import {
  LayoutDashboard, ListTodo, Columns3, Wallet, Clock, Palette,
  Users, Store, StickyNote, Sparkles, Menu, X, Heart, ChevronLeft, ChevronRight, Grid3X3, FolderOpen
} from 'lucide-react';
import ThemeToggle from './ThemeToggle';
import AIFab from './AIFab';
import { useWedding } from '@/contexts/WeddingContext';
import { PROJECT_LABELS, PROJECT_LIST, type ProjectId } from '@/lib/store';

const navItems = [
  { to: '/', label: 'Dashboard', icon: LayoutDashboard },
  { to: '/todo', label: 'Tâches', icon: ListTodo },
  { to: '/kanban', label: 'Kanban', icon: Columns3 },
  { to: '/budget', label: 'Budget', icon: Wallet },
  { to: '/timeline', label: 'Planning', icon: Clock },
  { to: '/guests', label: 'Invités', icon: Users },
  { to: '/vendors', label: 'Prestataires', icon: Store },
  { to: '/seating', label: 'Plan de Table', icon: Grid3X3 },
  { to: '/notes', label: 'Notes', icon: StickyNote },
  { to: '/da', label: 'Direction Artistique', icon: Palette },
  { to: '/ai', label: 'Assistant IA', icon: Sparkles },
];

function ProjectSelector({ collapsed }: { collapsed: boolean }) {
  const { data, setActiveProject } = useWedding();
  const [open, setOpen] = useState(false);

  if (collapsed) {
    return (
      <button
        onClick={() => setOpen(!open)}
        className="relative w-full flex items-center justify-center p-2 rounded-lg hover:bg-sidebar-accent transition-colors"
        title={PROJECT_LABELS[data.activeProject]}
      >
        <FolderOpen className="w-4 h-4 text-accent" />
        {open && (
          <div className="absolute left-full ml-2 top-0 z-50 bg-card border border-border rounded-xl shadow-elevated p-2 min-w-[200px]">
            {(['all', ...PROJECT_LIST] as ProjectId[]).map(p => (
              <button
                key={p}
                onClick={() => { setActiveProject(p); setOpen(false); }}
                className={`w-full text-left px-3 py-2 rounded-lg text-xs font-ui transition-colors ${
                  data.activeProject === p ? 'bg-accent text-accent-foreground font-semibold' : 'hover:bg-muted text-foreground'
                }`}
              >
                {PROJECT_LABELS[p]}
              </button>
            ))}
          </div>
        )}
      </button>
    );
  }

  return (
    <div className="px-3 py-2">
      <label className="text-[10px] uppercase tracking-wider text-muted-foreground font-ui font-semibold mb-1.5 block">Projet actif</label>
      <select
        value={data.activeProject}
        onChange={e => setActiveProject(e.target.value as ProjectId)}
        className="w-full px-2.5 py-2 rounded-lg border border-border bg-sidebar text-xs font-ui font-medium text-foreground"
      >
        {(['all', ...PROJECT_LIST] as ProjectId[]).map(p => (
          <option key={p} value={p}>{PROJECT_LABELS[p]}</option>
        ))}
      </select>
    </div>
  );
}

export default function Layout({ children }: { children: React.ReactNode }) {
  const location = useLocation();
  const [mobileOpen, setMobileOpen] = useState(false);
  const [collapsed, setCollapsed] = useState(false);

  return (
    <div className="flex h-screen overflow-hidden bg-background">
      {/* Desktop sidebar */}
      <aside className={`hidden md:flex flex-col border-r border-border bg-sidebar shrink-0 transition-all duration-300 ${collapsed ? 'w-16' : 'w-64'}`}>
        <div className={`flex items-center gap-2 px-4 py-4 border-b border-border ${collapsed ? 'justify-center' : ''}`}>
          <Heart className="w-5 h-5 text-accent shrink-0" fill="currentColor" />
          {!collapsed && <span className="font-script text-xl text-foreground tracking-tight">Flo & Thomy</span>}
        </div>

        {/* Project selector */}
        <div className="border-b border-border py-1">
          <ProjectSelector collapsed={collapsed} />
        </div>

        <nav className="flex-1 overflow-y-auto py-3 px-2 space-y-0.5">
          {navItems.map(item => {
            const active = location.pathname === item.to;
            return (
              <Link
                key={item.to}
                to={item.to}
                title={collapsed ? item.label : undefined}
                className={`flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-ui font-medium transition-all ${
                  active
                    ? 'bg-primary text-primary-foreground shadow-card'
                    : 'text-sidebar-foreground hover:bg-sidebar-accent'
                } ${collapsed ? 'justify-center' : ''}`}
              >
                <item.icon className="w-4 h-4 shrink-0" />
                {!collapsed && item.label}
              </Link>
            );
          })}
        </nav>
        <div className="border-t border-border p-2 flex items-center justify-between">
          <ThemeToggle />
          <button onClick={() => setCollapsed(c => !c)} className="p-2 rounded-lg hover:bg-muted transition-colors">
            {collapsed ? <ChevronRight className="w-4 h-4" /> : <ChevronLeft className="w-4 h-4" />}
          </button>
        </div>
      </aside>

      {/* Mobile header */}
      <div className="md:hidden fixed top-0 left-0 right-0 z-50 flex items-center justify-between px-4 py-3 border-b border-border bg-sidebar">
        <div className="flex items-center gap-2">
          <Heart className="w-4 h-4 text-accent" fill="currentColor" />
          <span className="font-script text-lg">Flo & Thomy</span>
        </div>
        <div className="flex items-center gap-1">
          <ThemeToggle />
          <button onClick={() => setMobileOpen(!mobileOpen)} className="p-2">
            {mobileOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
          </button>
        </div>
      </div>

      {/* Mobile menu */}
      <AnimatePresence>
        {mobileOpen && (
          <motion.div
            initial={{ opacity: 0, x: -280 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -280 }}
            className="md:hidden fixed inset-0 z-40 flex"
          >
            <div className="w-64 bg-sidebar border-r border-border pt-16 overflow-y-auto">
              <ProjectSelector collapsed={false} />
              <nav className="px-3 py-4 space-y-0.5">
                {navItems.map(item => {
                  const active = location.pathname === item.to;
                  return (
                    <Link
                      key={item.to}
                      to={item.to}
                      onClick={() => setMobileOpen(false)}
                      className={`flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-ui font-medium transition-all ${
                        active ? 'bg-primary text-primary-foreground' : 'text-sidebar-foreground hover:bg-sidebar-accent'
                      }`}
                    >
                      <item.icon className="w-4 h-4" />
                      {item.label}
                    </Link>
                  );
                })}
              </nav>
            </div>
            <div className="flex-1 bg-foreground/20" onClick={() => setMobileOpen(false)} />
          </motion.div>
        )}
      </AnimatePresence>

      {/* Main content */}
      <main className="flex-1 overflow-y-auto md:pt-0 pt-14">
        <div className="p-4 md:p-8 max-w-7xl mx-auto">
          {children}
        </div>
      </main>

      {/* AI FAB */}
      <AIFab />
    </div>
  );
}
