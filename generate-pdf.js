#!/usr/bin/env node

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

async function generatePDF() {
  const resumePath = process.argv[2] || './resume.json';
  const htmlPath = process.argv[3] || './resume.html';
  const outputPath = process.argv[4] || './resume.pdf';

  console.log('Loading resume data from:', resumePath);
  console.log('Loading HTML from:', htmlPath);
  console.log('Output PDF to:', outputPath);

  // Read the HTML file
  const html = fs.readFileSync(htmlPath, 'utf8');

  console.log('Launching Chromium...');
  const browser = await puppeteer.launch({
    executablePath: '/usr/local/bin/chromium-wrapper',
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-gpu',
      '--disable-software-rasterizer',
      '--disable-extensions'
    ],
    headless: true
  });

  try {
    console.log('Creating new page...');
    const page = await browser.newPage();

    console.log('Setting content...');
    await page.setContent(html, {
      waitUntil: 'networkidle0',
      timeout: 30000
    });

    // Wait a bit for styled-components to render
    await new Promise(resolve => setTimeout(resolve, 2000));

    console.log('Generating PDF...');
    await page.pdf({
      path: outputPath,
      format: 'A4',
      margin: {
        top: '20mm',
        right: '15mm',
        bottom: '20mm',
        left: '15mm'
      },
      printBackground: true,
      preferCSSPageSize: false
    });

    console.log('PDF generated successfully at:', outputPath);

    // Get file size
    const stats = fs.statSync(outputPath);
    console.log('PDF file size:', (stats.size / 1024).toFixed(2), 'KB');

  } catch (error) {
    console.error('Error generating PDF:', error);
    throw error;
  } finally {
    await browser.close();
  }
}

generatePDF()
  .then(() => {
    console.log('Done!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Fatal error:', error);
    process.exit(1);
  });