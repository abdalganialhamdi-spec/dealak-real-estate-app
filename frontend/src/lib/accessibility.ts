import { AxeResults, Result } from '@axe-core/react';

// Accessibility audit results interface
export interface AccessibilityAudit {
  timestamp: string;
  url: string;
  violations: Result[];
  passes: Result[];
  incomplete: Result[];
  score: {
    impact: {
      critical: number;
      serious: number;
      moderate: number;
      minor: number;
    };
  };
}

// Color contrast check
export function checkColorContrast(foreground: string, background: string, fontSize: number, fontWeight: number): {
  ratio: number;
  passes: boolean;
  level: 'AA' | 'AAA' | 'FAIL';
} {
  // Convert hex to RGB
  const hexToRgb = (hex: string) => {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16)
    } : null;
  };

  const fg = hexToRgb(foreground);
  const bg = hexToRgb(background);

  if (!fg || !bg) {
    return { ratio: 0, passes: false, level: 'FAIL' };
  }

  // Calculate relative luminance
  const getLuminance = (r: number, g: number, b: number) => {
    const [rs, gs, bs] = [r, g, b].map(c => {
      c = c / 255;
      return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
    });
    return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
  };

  const L1 = getLuminance(fg.r, fg.g, fg.b);
  const L2 = getLuminance(bg.r, bg.g, bg.b);

  // Calculate contrast ratio
  const lighter = Math.max(L1, L2);
  const darker = Math.min(L1, L2);
  const ratio = (lighter + 0.05) / (darker + 0.05);

  // Check WCAG compliance
  const isLargeText = fontSize >= 18 || (fontSize >= 14 && fontWeight >= 700);

  let passes = false;
  let level: 'AA' | 'AAA' | 'FAIL' = 'FAIL';

  if (isLargeText) {
    if (ratio >= 3) {
      passes = true;
      level = ratio >= 4.5 ? 'AAA' : 'AA';
    }
  } else {
    if (ratio >= 4.5) {
      passes = true;
      level = ratio >= 7 ? 'AAA' : 'AA';
    }
  }

  return { ratio: Math.round(ratio * 100) / 100, passes, level };
}

// Common color combinations for the app
export const colorCombinations = [
  { name: 'Primary Button', fg: '#ffffff', bg: '#2563eb', fontSize: 16, fontWeight: 500 },
  { name: 'Secondary Button', fg: '#111827', bg: '#e5e7eb', fontSize: 16, fontWeight: 500 },
  { name: 'Danger Button', fg: '#ffffff', bg: '#dc2626', fontSize: 16, fontWeight: 500 },
  { name: 'Ghost Button', fg: '#374151', bg: '#f3f4f6', fontSize: 16, fontWeight: 500 },
  { name: 'Heading', fg: '#111827', bg: '#ffffff', fontSize: 48, fontWeight: 700 },
  { name: 'Body Text', fg: '#4b5563', bg: '#ffffff', fontSize: 16, fontWeight: 400 },
  { name: 'Link', fg: '#2563eb', bg: '#ffffff', fontSize: 16, fontWeight: 400 },
  { name: 'Error Text', fg: '#dc2626', bg: '#ffffff', fontSize: 16, fontWeight: 400 },
  { name: 'Success Text', fg: '#16a34a', bg: '#ffffff', fontSize: 16, fontWeight: 400 },
  { name: 'Disabled Text', fg: '#9ca3af', bg: '#f3f4f6', fontSize: 16, fontWeight: 400 },
];

// Run color contrast checks
export function runColorContrastChecks() {
  const results = colorCombinations.map(combo => {
    const result = checkColorContrast(combo.fg, combo.bg, combo.fontSize, combo.fontWeight);
    return {
      ...combo,
      ...result,
    };
  });

  const failures = results.filter(r => !r.passes);
  const passes = results.filter(r => r.passes);

  return {
    total: results.length,
    passes: passes.length,
    failures: failures.length,
    results,
    failures: failures,
  };
}

// Format accessibility report
export function formatAccessibilityReport(audit: AccessibilityAudit): string {
  const { violations, passes, incomplete, score } = audit;

  let report = `🎨 Accessibility Audit Report\n`;
  report += `═══════════════════════════════════════\n\n`;
  report += `📊 Summary:\n`;
  report += `  • Violations: ${violations.length}\n`;
  report += `  • Passes: ${passes.length}\n`;
  report += `  • Incomplete: ${incomplete.length}\n\n`;

  report += `🎯 Impact Score:\n`;
  report += `  • Critical: ${score.impact.critical}\n`;
  report += `  • Serious: ${score.impact.serious}\n`;
  report += `  • Moderate: ${score.impact.moderate}\n`;
  report += `  • Minor: ${score.impact.minor}\n\n`;

  if (violations.length > 0) {
    report += `❌ Violations:\n`;
    violations.forEach((v, i) => {
      report += `  ${i + 1}. ${v.id} - ${v.description}\n`;
      report += `     Impact: ${v.impact}\n`;
      report += `     Help: ${v.help}\n`;
      report += `     Help URL: ${v.helpUrl}\n\n`;
    });
  }

  if (incomplete.length > 0) {
    report += `⏳ Incomplete (Manual Review Required):\n`;
    incomplete.forEach((v, i) => {
      report += `  ${i + 1}. ${v.id} - ${v.description}\n`;
      report += `     Help: ${v.help}\n\n`;
    });
  }

  return report;
}
