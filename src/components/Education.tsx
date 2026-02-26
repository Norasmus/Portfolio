import { motion } from 'framer-motion';
import { GraduationCap, Award } from 'lucide-react';
import { useScrollReveal } from '../hooks/useScrollReveal';
import { education } from '../data/resumeData';

export default function Education() {
  const { ref, isVisible } = useScrollReveal();

  return (
    <section id="education" className="py-24 px-6">
      <div ref={ref} className="mx-auto max-w-4xl">
        <motion.h2
          initial={{ opacity: 0, y: 30 }}
          animate={isVisible ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-3xl md:text-4xl font-bold text-center mb-16"
        >
          <span className="text-emerald-accent">Education</span>
        </motion.h2>

        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isVisible ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="rounded-2xl bg-bg-surface border border-emerald-accent/10 p-8 text-center"
        >
          <GraduationCap size={40} className="text-emerald-accent mx-auto mb-4" />
          <h3 className="text-xl font-semibold text-text-primary mb-2">
            {education.school}
          </h3>
          <p className="text-text-muted mb-4">{education.degree}</p>
          <div className="inline-flex items-center gap-2 rounded-full bg-emerald-accent/10 px-4 py-2 text-sm text-emerald-accent">
            <Award size={16} />
            {education.highlight}
          </div>
        </motion.div>
      </div>
    </section>
  );
}
