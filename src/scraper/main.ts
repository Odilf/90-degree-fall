import { intro, confirm, multiselect, spinner as createSpinner, outro } from '@clack/prompts';
import puppeteer, { Browser } from 'puppeteer';
import { getPath } from './utils.js';
import { access } from "node:fs/promises"
// import { scrape as scrape_guardian } from './guardian.js';
// import { scrape as scrape_pundit } from './thegatewaypundit.js';

const spinner = createSpinner();

intro('Welcome to 90-degree-fall');

export type Month = 'november' | 'december';
export type Outlet = "guardian" | "pundit";

const outlets = await multiselect({
	message: 'Pick the outlet to scrape',
	options: [
		{ value: 'guardian', label: 'The Guardian' },
		{ value: 'pundit', label: 'The Gateway Pundit' },
	],
	required: true,
}) as Outlet[];

const months = await multiselect({
	message: 'Pick months',
	options: [
		{ value: 'november', label: 'November' },
		{ value: 'december', label: 'December' },
	],
	initialValues: ['november', 'december'],
	required: true,
}) as Month[];

const regenerate = await confirm({
	message: 'Regenerate files if they already exist?',
	initialValue: false,
});

const daysInMonth: Record<Month, number> = {
	"november": 30,
	"december": 31,
}

spinner.start("Initializing browser")

// Lazy loaded singleton, lol
let browser: Browser = null;
const getBrowser = async () => browser ?? (browser = await puppeteer.launch({ headless: "new" }));
// const getBrowser = async () => browser;

for (const outlet of outlets) {
	const scraper = await import(`./${outlet}.js`) as { scrape: (month: Month, day: number, browser: Browser) => Promise<void> };
	for (const month of months) {
		for (let day = 1; day <= daysInMonth[month]; day++) {
			const path = getPath(outlet, month, day);

			if (!regenerate) {
				try { await access(path); continue; } catch { }
			}

			spinner.message(`Scrapping ${month} ${day}`)

			await scraper.scrape(month as Month, day, await getBrowser());
		}
	}
}

spinner.stop();

browser?.close();

outro('Done!')
