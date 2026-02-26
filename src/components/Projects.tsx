import { motion } from 'framer-motion';
import { ExternalLink, FolderGit2 } from 'lucide-react';
import { useScrollReveal } from '../hooks/useScrollReveal';
import { projects } from '../data/resumeData';

export default function Projects() {
  const { ref, isVisible } = useScrollReveal();

  return (
    <section id="projects" className="py-24 px-6 bg-bg-surface/30">
      <div ref={ref} className="mx-auto max-w-6xl">
        <motion.h2
          initial={{ opacity: 0, y: 30 }}
          animate={isVisible ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-3xl md:text-4xl font-bold text-center mb-16"
        >
          Featured <span className="text-emerald-accent">Projects</span>
        </motion.h2>

        <div className="grid md:grid-cols-2 gap-8">
          {projects.map((proj, i) => (
            <motion.a
              key={proj.id}
              href={proj.githubUrl}
              target="_blank"
              rel="noopener noreferrer"
              initial={{ opacity: 0, y: 30 }}
              animate={isVisible ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.5, delay: i * 0.1 }}
              className="group rounded-2xl bg-bg-surface border border-emerald-accent/10 p-6 hover:border-emerald-accent/40 hover:shadow-[0_0_30px_rgba(16,185,129,0.08)] transition-all"
            >
              <div className="flex items-start justify-between mb-4">
                <FolderGit2 size={28} className="text-emerald-accent" />
                <ExternalLink
                  size={18}
                  className="text-text-muted group-hover:text-emerald-accent transition-colors"
                />
              </div>
              <h3 className="text-xl font-semibold text-text-primary group-hover:text-emerald-accent transition-colors mb-2">
                {proj.title}
              </h3>
              <p className="text-sm text-text-muted leading-relaxed mb-4">
                {proj.description}
              </p>
              <div className="flex flex-wrap gap-2">
                {proj.techTags.map((tag) => (
                  <span
                    key={tag}
                    className="rounded-full bg-emerald-accent/10 px-3 py-1 text-xs text-emerald-accent font-[family-name:var(--font-mono)]"
                  >
                    {tag}
                  </span>
                ))}
              </div>
            </motion.a>
          ))}
        </div>
      </div>
    </section>
  );
}
