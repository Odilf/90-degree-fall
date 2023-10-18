import { Browser } from 'puppeteer'
import { Month } from './main.js';
import { write } from './utils.js';

export async function scrape(month: Month, day: number, browser: Browser) {
	const month_str = month === "november" ? "nov" : "dec"

	const page = await browser.newPage();

	await page.goto(`https://www.theguardian.com/us-news/2022/${month_str}/${day.toString().padStart(2, '0')}/`);

	await page.$eval('a.js-headline-text', anchor => anchor.click());

	const article_div = await page.$(".article-body-viewer-selector") ?? await page.$("article");
	const article_text = await article_div.evaluate((div) => div.textContent.replace(/[^A-Za-z0-9]/g, " "));

	write(article_text, "guardian", month, day)
}
