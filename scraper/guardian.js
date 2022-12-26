import puppeteer from 'puppeteer';
import { writeFile } from 'fs';
async function scrape(month, day) {
    const browser = await puppeteer.launch({ headless: true });
    const page = await browser.newPage();
    await page.goto(`https://www.theguardian.com/us-news/2022/${month}/${day.toString().padStart(2, '0')}/`);
    await Promise.all([
        page.waitForNavigation(),
        await page.evaluate(() => {
            document.querySelector('a.js-headline-text').click();
        })
    ]);
    const article_text = await page.evaluate(() => {
        const div = document.querySelector('.article-body-viewer-selector');
        return div.textContent.replace(/[^A-Za-z0-9]/g, " ");
    });
    writeFile(`output/${month}/${day}.txt`, article_text, err => {
        if (err) {
            console.error(err);
            throw new Error("im sad :(" + month + day);
        }
        else {
            console.log(`Saved succesfully ${month}, ${day}`);
        }
    });
    browser.close();
}
for (let i = 9; i < 30; i++) {
    try {
        await scrape('nov', i);
    }
    catch (e) {
        console.warn(e);
    }
}
for (let i = 1; i < 31; i++) {
    try {
        await scrape('dec', i);
    }
    catch (e) {
        console.warn(e);
    }
}
