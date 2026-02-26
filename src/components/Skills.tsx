import { motion } from 'framer-motion';
import { useScrollReveal } from '../hooks/useScrollReveal';
import { skillCategories } from '../data/resumeData';

export default function Skills() {
  const { ref, isVisible } = useScrollReveal();

  return (
    <section id="skills" className="py-24 px-6 bg-bg-surface/30">
      <div ref={ref} className="mx-auto max-w-6xl">
        <motion.h2
          initial={{ opacity: 0, y: 30 }}
          animate={isVisible ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-3xl md:text-4xl font-bold text-center mb-16"
        >
          Technical <span className="text-emerald-accent">Skills</span>
        </motion.h2>

        <div className="grid sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {skillCategories.map((cat, ci) => (
            <motion.div
              key={cat.category}
              initial={{ opacity: 0, y: 30 }}
              animate={isVisible ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.5, delay: ci * 0.1 }}
              className="rounded-2xl bg-bg-surface border border-emerald-accent/10 p-6 hover:border-emerald-accent/30 transition-colors"
            >
              <h3 className="text-sm font-semibold text-emerald-accent uppercase tracking-wider mb-4">
                {cat.category}
              </h3>
              <div className="space-y-3">
                {cat.skills.map((skill) => (
                  <div key={skill.name}>
                    <div className="flex justify-between text-sm mb-1">
                      <span className="text-text-primary">{skill.name}</span>
                      <span className="text-text-muted font-[family-name:var(--font-mono)] text-xs">
                        {skill.level}%
                      </span>
                    </div>
                    <div className="h-1.5 rounded-full bg-bg-primary overflow-hidden">
                      <motion.div
                        initial={{ width: 0 }}
                        animate={isVisible ? { width: `${skill.level}%` } : {}}
                        transition={{ duration: 1, delay: ci * 0.1 + 0.3 }}
                        className="h-full rounded-full bg-gradient-to-r from-emerald-dark to-emerald-accent"
                      />
                    </div>
                  </div>
                ))}
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
