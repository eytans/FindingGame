const fs = require('fs');
const { JSDOM } = require('jsdom');

// Read the HTML file
const html = fs.readFileSync('index.html', 'utf-8');

// Create a JSDOM instance
const dom = new JSDOM(html, {
    runScripts: 'dangerously', // Allow scripts to run
    resources: 'usable',      // Allow external resources like images (though JSDOM won't actually render them)
    pretendToBeVisual: true,  // Helps with some layout-dependent scripts
});

// Capture console messages
const virtualConsole = dom.virtualConsole;
virtualConsole.on('log', (message) => {
    console.log('CONSOLE.LOG:', message);
});
virtualConsole.on('error', (message) => {
    console.error('CONSOLE.ERROR:', message);
});

// Try to set and read status message from test_page.js
const statusDivFromTestPage = dom.window.document.getElementById('status-message');
if (statusDivFromTestPage) {
    console.log("Attempting to set status-message from test_page.js");
    statusDivFromTestPage.textContent = "Set by test_page.js";
    console.log("STATUS MESSAGE after direct set by test_page.js:", statusDivFromTestPage.textContent);
} else {
    console.error("Could not find status-message div from test_page.js");
}

// Give the page some time for async operations (like image loading)
setTimeout(() => {
    // You can inspect the DOM here if needed, e.g.:
    const finalStatusDiv = dom.window.document.getElementById('status-message');
    if (finalStatusDiv) {
        console.log("FINAL STATUS MESSAGE CONTENT (after 5s delay):", finalStatusDiv.textContent);
    } else {
        console.error("Could not find status-message div after 5s delay from test_page.js");
    }
}, 5000); // Wait 5 seconds

// Note: JSDOM doesn't truly "load" images in a way that triggers onload/onerror
// in the same way a browser does for network requests.
// The main purpose here is to catch JavaScript errors during setup or from the Unsplash URL change.
// The console logs we added are the primary things to check.
console.log("JSDOM setup complete. Waiting for async operations...");
