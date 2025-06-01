import { TextToSpeech } from '@capacitor-community/text-to-speech';

// Cross-platform speech wrapper
async function speak(text, options = {}) {
  if (window.Capacitor) {
    // Mobile app - use Capacitor plugin
    await TextToSpeech.speak({
      text: text,
      lang: options.lang || 'en-US',
      rate: options.rate || 1.0,
      pitch: options.pitch || 1.0,
      volume: options.volume || 1.0
    });
  } else {
    // Web browser - use Web Speech API
    return new Promise((resolve, reject) => {
      const utterance = new SpeechSynthesisUtterance(text);
      if (options.lang) utterance.lang = options.lang;
      if (options.rate) utterance.rate = options.rate;
      if (options.pitch) utterance.pitch = options.pitch;
      if (options.volume) utterance.volume = options.volume;
      
      utterance.onend = () => resolve();
      utterance.onerror = (error) => reject(error);
      
      window.speechSynthesis.cancel(); // Cancel any ongoing speech
      window.speechSynthesis.speak(utterance);
    });
  }
}

console.log("WordBubbles: Learn & Play loaded!");

let preloadedImage = null;
let currentImageId = null;

function getRandomImageId() {
    return Math.floor(Math.random() * 387) + 1;
}

function preloadNextImage() {
    const width = document.getElementById('image-area')?.offsetWidth || 800;
    const height = document.getElementById('image-area')?.offsetHeight || 600;
    
    const nextId = getRandomImageId();
    const img = new Image();
    
    return new Promise((resolve, reject) => {
        img.onload = () => {
            preloadedImage = img;
            currentImageId = nextId;
            resolve(img);
        };
        img.onerror = reject;
        img.src = `https://picsum.photos/id/${nextId}/${width}/${height}`;
    });
}

function loadBackgroundImage() {
    const imageArea = document.getElementById('image-area');
    if (!imageArea) {
        console.error('Error: image-area element not found!');
        return;
    }

    // Try to use preloaded image if available
    if (preloadedImage) {
        console.log(`Using preloaded background image: ${preloadedImage.src}`);
        imageArea.innerHTML = ''; // Clear loading message
        imageArea.style.backgroundImage = `url('${preloadedImage.src}')`;
        preloadedImage = null; // Clear the preloaded image
        // Start preloading next image for future use
        preloadNextImage().catch(err => console.warn('Failed to preload next image:', err));
        displayTeachableObjects();
        return;
    }

    // If no preloaded image, load one directly
    const width = imageArea.offsetWidth || 800;
    const height = imageArea.offsetHeight || 600;
    const imageId = getRandomImageId();

    const img = new Image();
    img.onload = () => {
        console.log(`Background image loaded successfully: ${img.src}`);
        imageArea.innerHTML = ''; // Clear loading message
        imageArea.style.backgroundImage = `url('${img.src}')`;
        // Preload next image for future use
        preloadNextImage().catch(err => console.warn('Failed to preload next image:', err));
        displayTeachableObjects();
    };
    img.onerror = () => {
        console.error(`Error loading background image. URL: ${img.src}`);
        if (imageArea) {
            imageArea.innerHTML = '<p style="text-align:center; padding-top: 50px; color: #555;">Could not load image. Enjoy the words on a plain background!</p>';
        }
        displayTeachableObjects(); // Still display words even if image fails
    };
    img.src = `https://picsum.photos/id/${imageId}/${width}/${height}`;
}

let animationFrameId = null; // To control animation loop

let wordsClickedCount = 0;
let setsCompletedCount = 0;
let currentWords = [];

const teachableWords = [
    // Original 20
    { word: "flower", type: "noun", iconUrl: "🌸" },
    { word: "circle", type: "shape", iconUrl: "●" },
    { word: "red square", type: "color", iconUrl: "🟥" },
    { word: "tree", type: "noun", iconUrl: "🌳" },
    { word: "square", type: "shape", iconUrl: "■" },
    { word: "blue square", type: "color", iconUrl: "🟦" },
    { word: "sun", type: "noun", iconUrl: "☀️" },
    { word: "star", type: "shape", iconUrl: "⭐" },
    { word: "yellow square", type: "color", iconUrl: "🟨" },
    { word: "car", type: "noun", iconUrl: "🚗" },
    { word: "cat", type: "animal", iconUrl: "🐱" },
    { word: "dog", type: "animal", iconUrl: "🐶" },
    { word: "apple", type: "food", iconUrl: "🍎" },
    { word: "banana", type: "food", iconUrl: "🍌" },
    { word: "book", type: "object", iconUrl: "📖" },
    { word: "chair", type: "object", iconUrl: "🪑" },
    { word: "house", type: "place", iconUrl: "🏠" },
    { word: "ball", type: "toy", iconUrl: "⚽" },
    { word: "moon", type: "celestial", iconUrl: "🌙" },
    { word: "hat", type: "clothing", iconUrl: "🧢" },
    // New 80 words
    { word: "bird", type: "animal", iconUrl: "🐦" },
    { word: "fish", type: "animal", iconUrl: "🐠" },
    { word: "lion", type: "animal", iconUrl: "🦁" },
    { word: "tiger", type: "animal", iconUrl: "🐅" },
    { word: "bear", type: "animal", iconUrl: "🐻" },
    { word: "elephant", type: "animal", iconUrl: "🐘" },
    { word: "monkey", type: "animal", iconUrl: "🐒" },
    { word: "horse", type: "animal", iconUrl: "🐎" },
    { word: "cow", type: "animal", iconUrl: "🐄" },
    { word: "pig", type: "animal", iconUrl: "🐖" },
    { word: "orange", type: "food", iconUrl: "🍊" },
    { word: "grapes", type: "food", iconUrl: "🍇" },
    { word: "strawberry", type: "food", iconUrl: "🍓" },
    { word: "watermelon", type: "food", iconUrl: "🍉" },
    { word: "pizza", type: "food", iconUrl: "🍕" },
    { word: "burger", type: "food", iconUrl: "🍔" },
    { word: "ice cream", type: "food", iconUrl: "🍦" },
    { word: "cake", type: "food", iconUrl: "🍰" },
    { word: "cookie", type: "food", iconUrl: "🍪" },
    { word: "milk", type: "drink", iconUrl: "🥛" },
    { word: "juice", type: "drink", iconUrl: "🧃" },
    { word: "water", type: "drink", iconUrl: "💧" },
    // { word: "tree trunk", type: "furniture", iconUrl: "🪵" }, // Using wood log as proxy for table
    { word: "bed", type: "furniture", iconUrl: "🛏️" },
    { word: "sofa", type: "furniture", iconUrl: "🛋️" },
    { word: "lamp", type: "furniture", iconUrl: "💡" },
    { word: "shirt", type: "clothing", iconUrl: "👕" },
    { word: "pants", type: "clothing", iconUrl: "👖" },
    { word: "shoe", type: "clothing", iconUrl: "👟" },
    { word: "dress", type: "clothing", iconUrl: "👗" },
    { word: "socks", type: "clothing", iconUrl: "🧦" },
    { word: "train", type: "vehicle", iconUrl: "🚆" },
    { word: "bus", type: "vehicle", iconUrl: "🚌" },
    { word: "bicycle", type: "vehicle", iconUrl: "🚲" },
    { word: "boat", type: "vehicle", iconUrl: "⛵" },
    { word: "airplane", type: "vehicle", iconUrl: "✈️" },
    { word: "helicopter", type: "vehicle", iconUrl: "🚁" },
    { word: "rocket", type: "vehicle", iconUrl: "🚀" },
    { word: "happy", type: "emotion", iconUrl: "😊" },
    { word: "sad", type: "emotion", iconUrl: "😢" },
    { word: "angry", type: "emotion", iconUrl: "😠" },
    { word: "surprised", type: "emotion", iconUrl: "😮" },
    // { word: "love", type: "emotion", iconUrl: "❤️" },
    { word: "laugh", type: "action", iconUrl: "😂" },
    { word: "cry", type: "action", iconUrl: "😭" },
    { word: "run", type: "action", iconUrl: "🏃" },
    // { word: "jump", type: "action", iconUrl: "🤸" },
    { word: "dance", type: "action", iconUrl: "💃" },
    // { word: "sing", type: "action", iconUrl: "🎤" },
    { word: "books", type: "action", iconUrl: "📚" },
    // { word: "play", type: "action", iconUrl: "▶️" }, // Generic play
    { word: "sleep", type: "action", iconUrl: "😴" },
    { word: "plate", type: "action", iconUrl: "🍽️" },
    { word: "drink", type: "action", iconUrl: "🥤" },
    { word: "green circle", type: "color", iconUrl: "🟢" },
    { word: "purple circle", type: "color", iconUrl: "🟣" },
    { word: "orange circle", type: "color", iconUrl: "🟠" }, // Color orange
    { word: "black circle", type: "color", iconUrl: "⚫" },
    { word: "white circle", type: "color", iconUrl: "⚪" },
    { word: "brown circle", type: "color", iconUrl: "🟤" },
    // { word: "pink", type: "color", iconUrl: "🩷" }, // Pink heart as proxy
    { word: "triangle", type: "shape", iconUrl: "🔺" },
    { word: "diamond", type: "shape", iconUrl: "💎" },
    { word: "egg", type: "shape", iconUrl: "🥚" }, // Egg as proxy for oval
    { word: "heart", type: "shape", iconUrl: "❤️" }, // Shape heart
    { word: "cloud", type: "nature", iconUrl: "☁️" },
    { word: "rain", type: "nature", iconUrl: "🌧️" },
    { word: "snow", type: "nature", iconUrl: "❄️" },
    { word: "mountain", type: "nature", iconUrl: "⛰️" },
    { word: "river", type: "nature", iconUrl: "🏞️" }, // National park as proxy
    { word: "wave", type: "nature", iconUrl: "🌊" },
    { word: "fire", type: "nature", iconUrl: "🔥" },
    { word: "earth", type: "celestial", iconUrl: "🌍" },
    { word: "computer", type: "object", iconUrl: "💻" },
    { word: "phone", type: "object", iconUrl: "📱" },
    { word: "key", type: "object", iconUrl: "🔑" },
    { word: "door", type: "object", iconUrl: "🚪" },
    { word: "picture", type: "object", iconUrl: "🖼️" }, // Framed picture as proxy
    { word: "clock", type: "object", iconUrl: "⏰" },
    { word: "guitar", type: "instrument", iconUrl: "🎸" },
    { word: "piano", type: "instrument", iconUrl: "🎹" },
    { word: "drum", type: "instrument", iconUrl: "🥁" },
    { word: "pencil", type: "tool", iconUrl: "✏️" }
];

const MAX_OBJECTS_ON_SCREEN = 3;

function initializeWordPool() {
    currentWords = []; // Clear
    // Select 20 random words from teachableWords
    const shuffledTeachable = [...teachableWords].sort(() => 0.5 - Math.random());
    currentWords = shuffledTeachable.slice(0, 20);
    console.log("Word pool initialized with 20 words.");
}

document.addEventListener('DOMContentLoaded', () => {
    // Preload first image before starting
    preloadNextImage()
        .then(() => {
            loadBackgroundImage();
            initializeWordPool();
        })
        .catch(err => {
            console.warn('Failed to preload initial image:', err);
            loadBackgroundImage(); // Fall back to direct loading
            initializeWordPool();
        });
});

function loadNextImage() {
    loadBackgroundImage();
}

async function speakWord(word, element) {
    const imageArea = document.getElementById('image-area');
    wordsClickedCount++;
    
    if (element) {
        element.classList.add('active');
    }

    try {
        await speak(word, {
            lang: 'en-US',
            rate: 0.9,
            pitch: 1.0,
            volume: 1.0
        });
        
        handleWordRemoval();
    } catch (error) {
        console.warn("Speech synthesis failed:", error);
        alert("Sorry, speech synthesis failed. Please try again!");
        if (element) {
            element.classList.remove('active');
        }
    }

    function handleWordRemoval() {
        if (element && element.parentNode) {
            element.classList.remove('active');
            element.remove();
        }
        if (imageArea) {
            const remainingObjects = imageArea.querySelectorAll('.teachable-object');
            if (remainingObjects.length === 0) {
                setsCompletedCount++;
                if (setsCompletedCount >= 3) {
                    loadNextImage();
                    setsCompletedCount = 0;
                    wordsClickedCount = 0;

                    const availableNewWords = teachableWords.filter(tw => !currentWords.some(cw => cw.word === tw.word));
                    const shuffledAvailable = availableNewWords.sort(() => 0.5 - Math.random());
                    const newWordsToAdd = shuffledAvailable.slice(0, 6);
                    currentWords.push(...newWordsToAdd);
                    console.log(`Added ${newWordsToAdd.length} new words. Current pool size: ${currentWords.length}`);
                } else {
                    displayTeachableObjects();
                }
            }
        }
    }
}

function displayTeachableObjects() {
    const imageArea = document.getElementById('image-area');
    if (!imageArea) return;

    const existingObjects = imageArea.querySelectorAll('.teachable-object');
    existingObjects.forEach(obj => obj.remove());

    // If there's a paragraph (e.g. error message), don't place words on top if it's the only child
    if (imageArea.childElementCount > 0 && imageArea.firstElementChild && imageArea.firstElementChild.tagName === 'P') {
        // Potentially adjust word placement or skip adding if error message is prominent
        // For now, we'll let them overlap or be less visible if background fails.
    }

    // Ensure there are words to display, if not, re-initialize pool (should be rare)
    if (currentWords.length === 0) {
        console.warn("CurrentWords is empty, re-initializing pool.");
        initializeWordPool();
        // If still empty, then teachableWords is empty or too small, which is a bigger issue.
        if (currentWords.length === 0) {
            console.error("Failed to populate currentWords even after re-initialization. Check teachableWords.");
            return; // Cannot display objects
        }
    }

    const wordsToDisplay = getRandomWords(currentWords, MAX_OBJECTS_ON_SCREEN);

    wordsToDisplay.forEach(item => {
        const objectElement = document.createElement('div');
        objectElement.classList.add('teachable-object');
        objectElement.dataset.word = item.word; // Keep this for click functionality

        if (item.iconUrl && (item.iconUrl.startsWith('http') || item.iconUrl.startsWith('https'))) {
            const imgElement = document.createElement('img');
            imgElement.src = item.iconUrl;
            imgElement.alt = item.word; // For accessibility
            objectElement.appendChild(imgElement);
        } else { // Not a URL
            if (item.iconUrl) { // It's an emoji/character
                objectElement.textContent = item.iconUrl;
                objectElement.classList.add('teachable-object-emoji');
            } else { // No iconUrl, display the word
                objectElement.textContent = item.word;
                objectElement.classList.add('teachable-object-text');
            }
        }

        // Set initial random position and velocity for animation
        objectElement.dx = (Math.random() - 0.5) * 2; // Velocity for x-axis (pixels per frame)
        objectElement.dy = (Math.random() - 0.5) * 2; // Velocity for y-axis (pixels per frame)

        // Ensure imageArea has dimensions before trying to place objects
        const areaWidth = imageArea.offsetWidth;
        const areaHeight = imageArea.offsetHeight;
        const objectWidth = objectElement.offsetWidth || 120; // Use actual or default if not rendered yet
        const objectHeight = objectElement.offsetHeight || 120;

        if (areaWidth > 0 && areaHeight > 0) {
            // Ensure objects are placed fully within bounds initially
            const maxX = areaWidth - objectWidth;
            const maxY = areaHeight - objectHeight;
            objectElement.style.left = `${Math.random() * Math.max(0, maxX)}px`;
            objectElement.style.top = `${Math.random() * Math.max(0, maxY)}px`;
        } else {
            // Fallback if imageArea has no dimensions (e.g., display:none or not yet rendered)
            objectElement.style.left = `${Math.random() * 50 + 25}%`; // Percentage based
            objectElement.style.top = `${Math.random() * 50 + 25}%`;
            console.warn("image-area has no dimensions, using percentage-based initial positioning.");
        }

        objectElement.addEventListener('click', async (event) => {
            const clickedWord = event.currentTarget.dataset.word;
            if (clickedWord && !event.currentTarget.dataset.clicked) { // Add clicked check
                // Stop its movement by setting dx/dy to 0 before speaking and removing
                event.currentTarget.dx = 0;
                event.currentTarget.dy = 0;
                event.currentTarget.dataset.clicked = 'true'; // Mark as clicked
                await speakWord(clickedWord, event.currentTarget);
            }
        });
        imageArea.appendChild(objectElement);
    });

    if (animationFrameId) {
        cancelAnimationFrame(animationFrameId);
    }
    animationFrameId = requestAnimationFrame(updateIconPositions);
}


function updateIconPositions() {
    const imageArea = document.getElementById('image-area');
    if (!imageArea) return;

    const icons = imageArea.querySelectorAll('.teachable-object');
    const areaWidth = imageArea.offsetWidth;
    const areaHeight = imageArea.offsetHeight;

    icons.forEach(icon => {
        if (!icon.parentNode) return; // Skip if icon was removed (e.g. by speakWord)

        let currentLeft = parseFloat(icon.style.left || 0);
        let currentTop = parseFloat(icon.style.top || 0);
        const iconWidth = icon.offsetWidth;
        const iconHeight = icon.offsetHeight;

        // Update position
        currentLeft += icon.dx || 0;
        currentTop += icon.dy || 0;

        // Collision detection and response
        // Left edge
        if (currentLeft < 0) {
            currentLeft = 0;
            icon.dx *= -1;
        }
        // Right edge
        if (currentLeft + iconWidth > areaWidth) {
            currentLeft = areaWidth - iconWidth;
            icon.dx *= -1;
        }
        // Top edge
        if (currentTop < 0) {
            currentTop = 0;
            icon.dy *= -1;
        }
        // Bottom edge
        if (currentTop + iconHeight > areaHeight) {
            currentTop = areaHeight - iconHeight;
            icon.dy *= -1;
        }

        icon.style.left = `${currentLeft}px`;
        icon.style.top = `${currentTop}px`;
    });

    animationFrameId = requestAnimationFrame(updateIconPositions);
}


function getRandomWords(wordsArray, count) {
    const shuffled = [...wordsArray].sort(() => 0.5 - Math.random());
    return shuffled.slice(0, count);
}

if ('serviceWorker' in navigator) {
window.addEventListener('load', () => {
    navigator.serviceWorker.register('./service-worker.js')  // Updated path
    .then(registration => {
        console.log('ServiceWorker registration successful with scope: ', registration.scope);
    })
    .catch(error => {
        console.log('ServiceWorker registration failed: ', error);
    });
});
}
