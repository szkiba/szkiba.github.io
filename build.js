import { promises as fs } from 'fs'
import * as theme from 'jsonresume-theme-stackoverflow'
import puppeteer from 'puppeteer'
import { render } from 'resumed'
import YAML from 'yaml'

const resume = YAML.parse(await fs.readFile('resume.yaml', 'utf-8'))
const html = await render(resume, theme)
await fs.writeFile("index.html", html)

const browser = await puppeteer.launch({headless: "new"})
const page = await browser.newPage()

await page.setContent(html, { waitUntil: 'networkidle0' })
await page.pdf({ path: 'resume.pdf', format: 'a4', printBackground: true })
await browser.close()