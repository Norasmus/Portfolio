import { motion } from 'framer-motion';
import { Mail, Github, Linkedin } from 'lucide-react';
import { useScrollReveal } from '../hooks/useScrollReveal';
import { personalInfo } from '../data/resumeData';

export default function Contact() {
  const { ref, isVisible } = useScrollReveal();

  return (
    <section id="contact" className="py-24 px-6 bg-bg-surface/30">
      <div ref={ref} className="mx-auto max-w-2xl text-center">
        <motion.h2
          initial={{ opacity: 0, y: 30 }}
          animate={isVisible ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-3xl md:text-4xl font-bold mb-6"
        >
          Let's <span className="text-emerald-accent">Connect</span>
        </motion.h2>

        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={isVisible ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="text-text-muted mb-10 leading-relaxed"
        >
          I'm always open to discussing data engineering challenges, BI strategy,
          or new opportunities. Feel free to reach out.
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isVisible ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="flex flex-col sm:flex-row gap-4 justify-center"
        >
          <a
            href={`mailto:${personalInfo.email}`}
            className="inline-flex items-center justify-center gap-2 rounded-lg bg-emerald-accent px-8 py-3 text-bg-primary font-semibold hover:bg-emerald-dark transition-colors"
          >
            <Mail size={18} />
            Say Hello
          </a>
          <a
            href={personalInfo.github}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center justify-center gap-2 rounded-lg border border-emerald-accent/30 px-8 py-3 text-emerald-accent hover:bg-emerald-accent/10 transition-colors"
          >
            <Github size={18} />
            GitHub
          </a>
          <a
            href={personalInfo.linkedin}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center justify-center gap-2 rounded-lg border border-emerald-accent/30 px-8 py-3 text-emerald-accent hover:bg-emerald-accent/10 transition-colors"
          >
            <Linkedin size={18} />
            LinkedIn
          </a>
        </motion.div>
      </div>
    </section>
  );
}
