import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { ArrowDown, Github } from 'lucide-react';
import ParticleNetwork from './ParticleNetwork';
import { personalInfo } from '../data/resumeData';

export default function Hero() {
  const [descriptorIndex, setDescriptorIndex] = useState(0);
  const [displayed, setDisplayed] = useState('');
  const [typing, setTyping] = useState(true);

  useEffect(() => {
    const word = personalInfo.descriptors[descriptorIndex];
    let timeout: ReturnType<typeof setTimeout>;

    if (typing) {
      if (displayed.length < word.length) {
        timeout = setTimeout(() => setDisplayed(word.slice(0, displayed.length + 1)), 80);
      } else {
        timeout = setTimeout(() => setTyping(false), 1800);
      }
    } else {
      if (displayed.length > 0) {
        timeout = setTimeout(() => setDisplayed(displayed.slice(0, -1)), 40);
      } else {
        setDescriptorIndex((i) => (i + 1) % personalInfo.descriptors.length);
        setTyping(true);
      }
    }

    return () => clearTimeout(timeout);
  }, [displayed, typing, descriptorIndex]);

  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden">
      <ParticleNetwork />
      <div className="relative z-10 text-center px-6 max-w-4xl mx-auto">
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="text-text-muted text-lg mb-4"
        >
          Hello, I'm
        </motion.p>
        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="text-5xl md:text-7xl font-extrabold mb-4"
        >
          {personalInfo.name}
        </motion.h1>
        <motion.h2
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
          className="text-2xl md:text-3xl text-emerald-accent font-semibold mb-6"
        >
          {personalInfo.title}
        </motion.h2>
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.8 }}
          className="h-8 mb-8"
        >
          <span className="font-[family-name:var(--font-mono)] text-text-muted text-lg">
            {displayed}
            <span className="animate-pulse text-emerald-accent">|</span>
          </span>
        </motion.div>
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 1 }}
          className="flex flex-col sm:flex-row gap-4 justify-center"
        >
          <a
            href="#projects"
            className="inline-flex items-center justify-center gap-2 rounded-lg bg-emerald-accent px-8 py-3 text-bg-primary font-semibold hover:bg-emerald-dark transition-colors"
          >
            View Projects
            <ArrowDown size={16} />
          </a>
          <a
            href={personalInfo.github}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center justify-center gap-2 rounded-lg border border-emerald-accent/30 px-8 py-3 text-emerald-accent hover:bg-emerald-accent/10 transition-colors"
          >
            <Github size={16} />
            GitHub
          </a>
        </motion.div>
      </div>
    </section>
  );
}
