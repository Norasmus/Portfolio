import { motion } from 'framer-motion';
import { useScrollReveal } from '../hooks/useScrollReveal';
import { useCountUp } from '../hooks/useCountUp';
import { impactMetrics } from '../data/resumeData';

function MetricCard({ label, value, prefix = '', suffix = '' }: {
  label: string;
  value: number;
  prefix?: string;
  suffix?: string;
}) {
  const { ref, isVisible } = useScrollReveal(0.3);
  const count = useCountUp(value, 2000, isVisible);

  return (
    <div ref={ref} className="text-center px-4 py-6">
      <p className="text-3xl md:text-4xl font-bold text-emerald-accent font-[family-name:var(--font-mono)]">
        {prefix}{count}{suffix}
      </p>
      <p className="text-sm text-text-muted mt-1">{label}</p>
    </div>
  );
}

export default function ImpactMetrics() {
  return (
    <section className="border-y border-emerald-accent/10 bg-bg-surface/50">
      <motion.div
        initial={{ opacity: 0 }}
        whileInView={{ opacity: 1 }}
        viewport={{ once: true }}
        className="mx-auto max-w-7xl grid grid-cols-2 md:grid-cols-5 gap-2 py-4"
      >
        {impactMetrics.map((m) => (
          <MetricCard key={m.label} {...m} />
        ))}
      </motion.div>
    </section>
  );
}
