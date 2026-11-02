import { parse } from "yaml";
import raw from "../../resume.yaml?raw";

export interface Profile {
  network: string;
  username?: string;
  url: string;
}

export interface Basics {
  name: string;
  label: string;
  headline?: string;
  summary?: string;
  image?: string;
  url: string;
  email?: string;
  phone?: string;
  location?: { region?: string; countryCode?: string };
  profiles: Profile[];
}

export interface Work {
  name: string;
  position: string;
  url?: string;
  location?: string;
  summary?: string;
  startDate: string;
  endDate?: string;
  highlights?: string[];
}

export interface Project {
  name: string;
  url?: string;
  summary?: string;
}

export interface Education {
  institution: string;
  studyType: string;
  url?: string;
  startDate: string;
  endDate?: string;
}

export interface Resume {
  basics: Basics;
  work: Work[];
  projects: Project[];
  skills: { name: string; level?: string }[];
  education: Education[];
  languages: { language: string; fluency: string }[];
  interests: { name: string }[];
}

export const resume = parse(raw) as Resume;

const month = new Intl.DateTimeFormat("en", { month: "short", year: "numeric", timeZone: "UTC" });

export function formatDate(date?: string): string {
  return date ? month.format(new Date(date)) : "Present";
}

export function formatRange(start: string, end?: string): string {
  return `${formatDate(start)} – ${formatDate(end)}`;
}

export function formatYearRange(start: string, end?: string): string {
  return `${start.slice(0, 4)} – ${end ? end.slice(0, 4) : "Present"}`;
}

// Highlights wrapped in parentheses list the technologies used in a role.
export function splitHighlights(highlights: string[] = []) {
  const isTech = (h: string) => h.startsWith("(") && h.endsWith(")");

  return {
    items: highlights.filter((h) => !isTech(h)),
    tech: highlights.filter(isTech).map((h) => h.slice(1, -1)),
  };
}

export interface Employer {
  name: string;
  url?: string;
  location?: string;
  roles: Work[];
}

// Consecutive roles at the same company are shown under a single heading.
export function groupByEmployer(work: Work[]): Employer[] {
  const groups: Employer[] = [];

  for (const role of work) {
    const last = groups.at(-1);

    if (last?.name === role.name) {
      last.roles.push(role);
    } else {
      groups.push({ name: role.name, url: role.url, location: role.location, roles: [role] });
    }
  }

  return groups;
}

// Project names follow the "name - description" convention.
export function splitProject(project: Project) {
  const [title, ...rest] = project.name.split(" - ");

  return { title, description: rest.join(" - ") || project.summary };
}
