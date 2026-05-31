import { AxeBuilder } from '@axe-core/playwright';
import { chromium } from 'playwright';
import { pathToFileURL } from 'node:url';
import process from 'node:process';

const targetPath = process.argv[2] ?? 'docs/accessibility/axe-smoke.html';
const browser = await chromium.launch({ args: ['--no-sandbox'] });
const page = await browser.newPage();

await page.goto(pathToFileURL(targetPath).href);
const results = await new AxeBuilder({ page }).analyze();
await browser.close();

if (results.violations.length > 0) {
  console.error('axe violations found:');
  for (const violation of results.violations) {
    console.error(`- ${violation.id}: ${violation.help}`);
    for (const node of violation.nodes) {
      console.error(`  selector: ${node.target.join(', ')}`);
      console.error(`  summary: ${node.failureSummary ?? 'n/a'}`);
    }
  }
  process.exitCode = 1;
} else {
  console.log(`axe smoke check passed for ${targetPath}`);
}
