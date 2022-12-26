import puppeteer from 'puppeteer';
import { writeFile } from 'fs';
async function scrape(month, day) {
    const browser = await puppeteer.launch({ headless: true });
    const page = await browser.newPage();
    const url = `https://www.thegatewaypundit.com/2022/${month}/${day.toString().padStart(2, '0')}/`;
    console.log(url);
    await page.goto(url);
    await Promise.all([
        page.waitForNavigation(),
        await page.evaluate(() => {
            const as = document.querySelectorAll('a.post-link');
            for (const a of as) {
                console.log(a);
                if (!a.innerText.toLowerCase().includes("video")) {
                    console.log('navigating to ', a);
                    a.click();
                    return;
                }
            }
        })
    ]);
    console.log("Navigated. i think");
    const article_text = await page.evaluate(() => {
        const div = document.querySelector('.entry-content');
        return div.innerText.replace(/[^A-Za-z0-9]/g, " ");
    });
    writeFile(`pundit/${month}/${day}.txt`, article_text, err => {
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
for (let i = 1; i < 30; i++) {
    try {
        await scrape(11, i);
    }
    catch (e) {
        console.warn(e);
    }
}
for (let i = 1; i < 25; i++) {
    try {
        await scrape(12, i);
    }
    catch (e) {
        console.warn(e);
    }
}
