import { Github, Linkedin, Mail } from 'lucide-react';
import { personalInfo } from '../data/resumeData';

export default function Footer() {
  return (
    <footer className="border-t border-emerald-accent/10 py-8 px-6">
      <div className="mx-auto max-w-6xl flex flex-col md:flex-row items-center justify-between gap-4">
        <p className="text-sm text-text-muted">
          &copy; {new Date().getFullYear()} {personalInfo.name}. All rights reserved.
        </p>
        <div className="flex gap-4">
          <a
            href={personalInfo.github}
            target="_blank"
            rel="noopener noreferrer"
            className="text-text-muted hover:text-emerald-accent transition-colors"
            aria-label="GitHub"
          >
            <Github size={18} />
          </a>
          <a
            href={personalInfo.linkedin}
            target="_blank"
            rel="noopener noreferrer"
            className="text-text-muted hover:text-emerald-accent transition-colors"
            aria-label="LinkedIn"
          >
            <Linkedin size={18} />
          </a>
          <a
            href={`mailto:${personalInfo.email}`}
            className="text-text-muted hover:text-emerald-accent transition-colors"
            aria-label="Email"
          >
            <Mail size={18} />
          </a>
        </div>
      </div>
    </footer>
  );
}
