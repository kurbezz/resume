#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

async function injectDownloadButton() {
  const htmlPath = process.argv[2] || './resume.html';

  console.log('Reading HTML file:', htmlPath);
  let html = fs.readFileSync(htmlPath, 'utf8');

  // Create the download button HTML and styles matching the resume design
  const buttonHTML = `
    <style>
      .resume-download-button {
        position: fixed;
        bottom: 40px;
        right: 40px;
        background-color: #ffffff;
        color: #0b1f3a;
        padding: 10px 16px;
        border: 1.5px solid #0b1f3a;
        border-radius: 2px;
        text-decoration: none;
        font-weight: 500;
        cursor: pointer;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', sans-serif;
        font-size: 0.95rem;
        transition: all 0.2s ease;
        z-index: 1000;
        display: flex;
        align-items: center;
        gap: 8px;
        white-space: nowrap;
      }
      
      .resume-download-button:hover {
        background-color: #0b1f3a;
        color: white;
        border-color: #0b1f3a;
      }
      
      .resume-download-button:active {
        opacity: 0.8;
      }
      
      @media print {
        .resume-download-button {
          display: none !important;
        }
      }
      
      @media (max-width: 768px) {
        .resume-download-button {
          bottom: 24px;
          right: 24px;
          padding: 8px 12px;
          font-size: 0.875rem;
        }
      }
    </style>
    
    <a href="/resume.pdf" download="resume.pdf" class="resume-download-button">
      <span>↓</span> PDF
    </a>
  `;

  // Inject the button before the closing body tag
  if (html.includes('</body>')) {
    html = html.replace('</body>', buttonHTML + '</body>');
    fs.writeFileSync(htmlPath, html, 'utf8');
    console.log('Download button injected successfully!');
  } else {
    console.error('Could not find </body> tag in HTML file');
    process.exit(1);
  }
}

injectDownloadButton()
  .then(() => {
    console.log('Done!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Error:', error);
    process.exit(1);
  });