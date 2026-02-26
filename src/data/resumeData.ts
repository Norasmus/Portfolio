export const personalInfo = {
  name: 'Eric Severiano',
  title: 'Senior BI & Data Engineer',
  tagline: 'Transforming complex data into strategic business intelligence',
  descriptors: [
    'Data Engineering',
    'Business Intelligence',
    'Supply Chain Analytics',
    'Cloud Architecture',
    'Predictive Modeling',
  ],
  email: 'eric.severiano@example.com',
  github: 'https://github.com/Norasmus',
  linkedin: 'https://linkedin.com/in/',
  resumeUrl: '/resume.pdf',
};

export const impactMetrics = [
  { label: 'Operational Savings', value: 10, prefix: '$', suffix: 'M+' },
  { label: 'Years Experience', value: 10, suffix: '+' },
  { label: 'Manual Work Eliminated', value: 90, suffix: '%' },
  { label: 'Faster Query Execution', value: 40, suffix: '%' },
  { label: 'Better Forecasting', value: 25, suffix: '%' },
];

export const aboutText = [
  'With a unique background spanning psychology and data science, I bring a human-centered approach to complex data engineering challenges. My career has been defined by building scalable BI platforms that turn raw data into actionable insights.',
  'I specialize in designing end-to-end data pipelines, optimizing warehouse architectures, and delivering dashboards that empower decision-makers across supply chain, logistics, and operations.',
];

export const competencyAreas = [
  { area: 'Data Engineering', score: 95 },
  { area: 'Business Intelligence', score: 92 },
  { area: 'Cloud Architecture', score: 88 },
  { area: 'SQL & Databases', score: 95 },
  { area: 'Python / ETL', score: 90 },
  { area: 'Leadership', score: 85 },
];

export interface Skill {
  name: string;
  level: number;
}

export interface SkillCategory {
  category: string;
  skills: Skill[];
}

export const skillCategories: SkillCategory[] = [
  {
    category: 'Programming',
    skills: [
      { name: 'Python', level: 90 },
      { name: 'SQL', level: 95 },
      { name: 'R', level: 70 },
      { name: 'JavaScript', level: 65 },
    ],
  },
  {
    category: 'Data Engineering',
    skills: [
      { name: 'Apache Airflow', level: 85 },
      { name: 'dbt', level: 80 },
      { name: 'Spark', level: 75 },
      { name: 'Kafka', level: 70 },
    ],
  },
  {
    category: 'Cloud & Warehousing',
    skills: [
      { name: 'Snowflake', level: 90 },
      { name: 'Azure', level: 85 },
      { name: 'AWS', level: 80 },
      { name: 'BigQuery', level: 75 },
    ],
  },
  {
    category: 'BI Tools',
    skills: [
      { name: 'Power BI', level: 95 },
      { name: 'Tableau', level: 85 },
      { name: 'Looker', level: 75 },
      { name: 'SSRS', level: 80 },
    ],
  },
  {
    category: 'Infrastructure',
    skills: [
      { name: 'Docker', level: 80 },
      { name: 'Git / CI-CD', level: 85 },
      { name: 'Terraform', level: 65 },
      { name: 'Linux', level: 75 },
    ],
  },
  {
    category: 'ERP / WMS / TMS',
    skills: [
      { name: 'SAP', level: 80 },
      { name: 'Oracle', level: 75 },
      { name: 'Manhattan WMS', level: 70 },
      { name: 'Blue Yonder', level: 70 },
    ],
  },
  {
    category: 'AI / ML',
    skills: [
      { name: 'scikit-learn', level: 80 },
      { name: 'Time-Series Forecasting', level: 85 },
      { name: 'NLP Basics', level: 65 },
      { name: 'Prophet', level: 75 },
    ],
  },
];

export interface Experience {
  id: string;
  role: string;
  company: string;
  period: string;
  achievements: string[];
}

export const experiences: Experience[] = [
  {
    id: 'exp-1',
    role: 'Senior BI & Data Engineer',
    company: 'Enterprise Logistics Corp',
    period: '2021 – Present',
    achievements: [
      'Architected enterprise Snowflake data warehouse serving 500+ users across 12 departments',
      'Built automated ETL pipelines processing 2M+ records daily with 99.9% uptime',
      'Delivered executive dashboards that drove $10M+ in operational savings',
      'Led migration from on-prem SQL Server to cloud-native architecture',
    ],
  },
  {
    id: 'exp-2',
    role: 'BI Developer',
    company: 'Supply Chain Solutions Inc',
    period: '2018 – 2021',
    achievements: [
      'Designed star-schema data models for logistics KPI tracking',
      'Reduced manual reporting effort by 90% through Power BI automation',
      'Implemented predictive freight forecasting models improving accuracy by 25%',
      'Optimized SQL queries achieving 40% faster execution times',
    ],
  },
  {
    id: 'exp-3',
    role: 'Data Analyst',
    company: 'Regional Distribution Co',
    period: '2015 – 2018',
    achievements: [
      'Created inventory optimization models reducing stockouts by 30%',
      'Built first self-service BI portal for warehouse operations team',
      'Automated weekly reporting cycle from 8 hours to 15 minutes',
    ],
  },
];

export interface Project {
  id: string;
  title: string;
  description: string;
  techTags: string[];
  githubUrl: string;
  folder: string;
}

export const projects: Project[] = [
  {
    id: 'proj-1',
    title: 'Supply Chain Analytics',
    description:
      'Interactive supply chain KPI analysis with synthetic logistics data, cost-per-shipment trends, and warehouse throughput visualizations.',
    techTags: ['Python', 'pandas', 'Plotly', 'Jupyter'],
    githubUrl: 'https://github.com/Norasmus/Portfolio/tree/main/projects/supply-chain-analytics',
    folder: 'supply-chain-analytics',
  },
  {
    id: 'proj-2',
    title: 'ETL Pipeline Demo',
    description:
      'Modular ETL/ELT pipeline architecture with Airflow DAG definitions, YAML configuration, and extract/transform/load scripts.',
    techTags: ['Python', 'Airflow', 'YAML', 'Docker'],
    githubUrl: 'https://github.com/Norasmus/Portfolio/tree/main/projects/etl-pipeline-demo',
    folder: 'etl-pipeline-demo',
  },
  {
    id: 'proj-3',
    title: 'Predictive Freight Forecasting',
    description:
      'ML model for freight volume prediction using time-series forecasting with model evaluation and prediction visualizations.',
    techTags: ['Python', 'scikit-learn', 'Prophet', 'matplotlib'],
    githubUrl: 'https://github.com/Norasmus/Portfolio/tree/main/projects/predictive-freight-forecasting',
    folder: 'predictive-freight-forecasting',
  },
  {
    id: 'proj-4',
    title: 'SQL Analytics Warehouse',
    description:
      'Star-schema data warehouse with optimized views, stored procedures for KPI refresh, and complex analytical queries.',
    techTags: ['PostgreSQL', 'SQL', 'Star Schema', 'Analytics'],
    githubUrl: 'https://github.com/Norasmus/Portfolio/tree/main/projects/sql-analytics-warehouse',
    folder: 'sql-analytics-warehouse',
  },
];

export const education = {
  school: 'University of California, Santa Barbara',
  degree: 'Bachelor of Arts – Psychology',
  highlight: 'Scholar-Athlete Award Recipient',
};
