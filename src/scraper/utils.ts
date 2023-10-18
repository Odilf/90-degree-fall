import { writeFile, mkdir } from "node:fs/promises"
import { Outlet } from "./main.js";

function getDir(outlet: Outlet, month: string) {
	return `./output/scrapper/${outlet}/${month}`;
}

export function getPath(outlet: Outlet, month: string, day: number) {
	return `${getDir(outlet, month)}/${day.toString().padStart(2, '0')}.txt`;
}

export async function write(text: string, outlet: Outlet, month: string, day: number) {
	const dir = getDir(outlet, month);
	const path = getPath(outlet, month, day);
	
	try {
		await writeFile(path, text);
	} catch (err) {
		await mkdir(dir, { recursive: true });

		try {
			await writeFile(path, text);
		} catch (err) {
			console.error(err);
		}
	}
}
