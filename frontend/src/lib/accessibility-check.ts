import { runColorContrastChecks } from '@/lib/accessibility';

// Run accessibility checks
export function runAccessibilityChecks() {
  console.log('🎨 Running Accessibility Checks...\n');

  // Color contrast checks
  const contrastResults = runColorContrastChecks();

  console.log('📊 Color Contrast Results:');
  console.log(`  Total: ${contrastResults.total}`);
  console.log(`  Passes: ${contrastResults.passes}`);
  console.log(`  Failures: ${contrastResults.failures}\n`);

  if (contrastResults.failures.length > 0) {
    console.log('❌ Failed Color Contrast Checks:');
    contrastResults.failures.forEach((failure, i) => {
      console.log(`  ${i + 1}. ${failure.name}`);
      console.log(`     Ratio: ${failure.ratio}:1 (Required: ${failure.level === 'AA' ? '4.5:1' : '7:1'})`);
      console.log(`     Foreground: ${failure.fg}`);
      console.log(`     Background: ${failure.bg}`);
      console.log(`     Font Size: ${failure.fontSize}px`);
      console.log(`     Font Weight: ${failure.fontWeight}\n`);
    });
  } else {
    console.log('✅ All color contrast checks passed!\n');
  }

  // Detailed results
  console.log('📋 Detailed Results:');
  contrastResults.results.forEach((result, i) => {
    const status = result.passes ? '✅' : '❌';
    console.log(`  ${status} ${result.name}: ${result.ratio}:1 (${result.level})`);
  });

  console.log('\n🎯 Accessibility Score:');
  const score = Math.round((contrastResults.passes / contrastResults.total) * 100);
  console.log(`  ${score}% (${contrastResults.passes}/${contrastResults.total} checks passed)`);

  return {
    contrastResults,
    score,
  };
}

// Run this in development
if (typeof window !== 'undefined' && process.env.NODE_ENV === 'development') {
  // Expose to window for manual testing
  (window as any).runAccessibilityChecks = runAccessibilityChecks;
  console.log('💡 Accessibility checks available: runAccessibilityChecks()');
}
