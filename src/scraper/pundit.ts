import puppeteer, { Browser } from 'puppeteer'
import { writeFile } from 'fs'
import { Month } from './main.js';
import { write } from './utils.js';

export async function scrape(month: Month, day: number, browser: Browser) {
	const month_str = month === "november" ? 11 : 12

	const page = await browser.newPage();

	const url = `https://www.thegatewaypundit.com/2022/${month_str}/${day.toString().padStart(2, '0')}/`

	await page.goto(url);

	await page.$$eval('a.post-link', anchors => {
		for (const anchor of anchors) {
			if (!anchor.innerText.toLowerCase().includes("video")) {
				anchor.click()
				return
			}
		}
	})

	const article_div = await page.$(".entry-content") ?? await page.$("article");
	const article_text = await article_div.evaluate((div) => div.textContent.replace(/[^A-Za-z0-9]/g, " "));

	write(article_text, "pundit", month, day)
}
