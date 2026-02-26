import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronDown, Briefcase } from 'lucide-react';
import { useScrollReveal } from '../hooks/useScrollReveal';
import { experiences } from '../data/resumeData';

export default function Experience() {
  const { ref, isVisible } = useScrollReveal();
  const [expanded, setExpanded] = useState<string | null>(experiences[0].id);

  return (
    <section id="experience" className="py-24 px-6">
      <div ref={ref} className="mx-auto max-w-4xl">
        <motion.h2
          initial={{ opacity: 0, y: 30 }}
          animate={isVisible ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-3xl md:text-4xl font-bold text-center mb-16"
        >
          Work <span className="text-emerald-accent">Experience</span>
        </motion.h2>

        <div className="relative border-l-2 border-emerald-accent/20 ml-4 md:ml-8">
          {experiences.map((exp, i) => (
            <motion.div
              key={exp.id}
              initial={{ opacity: 0, x: -30 }}
              animate={isVisible ? { opacity: 1, x: 0 } : {}}
              transition={{ duration: 0.5, delay: i * 0.15 }}
              className="relative pl-10 pb-12 last:pb-0"
            >
              {/* Timeline dot */}
              <div className="absolute -left-[11px] top-1 w-5 h-5 rounded-full bg-bg-primary border-2 border-emerald-accent flex items-center justify-center">
                <Briefcase size={10} className="text-emerald-accent" />
              </div>

              <button
                onClick={() => setExpanded(expanded === exp.id ? null : exp.id)}
                className="w-full text-left group"
              >
                <div className="flex items-start justify-between">
                  <div>
                    <h3 className="text-lg font-semibold text-text-primary group-hover:text-emerald-accent transition-colors">
                      {exp.role}
                    </h3>
                    <p className="text-text-muted text-sm">{exp.company}</p>
                  </div>
                  <div className="flex items-center gap-2 shrink-0 ml-4">
                    <span className="text-xs text-text-muted font-[family-name:var(--font-mono)]">
                      {exp.period}
                    </span>
                    <ChevronDown
                      size={16}
                      className={`text-text-muted transition-transform ${
                        expanded === exp.id ? 'rotate-180' : ''
                      }`}
                    />
                  </div>
                </div>
              </button>

              <AnimatePresence>
                {expanded === exp.id && (
                  <motion.ul
                    initial={{ height: 0, opacity: 0 }}
                    animate={{ height: 'auto', opacity: 1 }}
                    exit={{ height: 0, opacity: 0 }}
                    transition={{ duration: 0.3 }}
                    className="overflow-hidden mt-3 space-y-2"
                  >
                    {exp.achievements.map((a, ai) => (
                      <li
                        key={ai}
                        className="text-sm text-text-muted flex gap-2 before:content-['▹'] before:text-emerald-accent before:shrink-0"
                      >
                        {a}
                      </li>
                    ))}
                  </motion.ul>
                )}
              </AnimatePresence>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
