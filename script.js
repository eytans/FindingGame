console.log("Word Learner Game script loaded!");

const imageUrls = [
    "images/image1.jpg",
    "images/image2.jpg",
    "images/image3.jpg",
    "images/image4.jpg",
    "images/image5.jpg",
    "images/image6.jpg",
    "images/image7.jpg",
    "images/image8.jpg",
    "images/image9.jpg",
    "images/image10.jpg"
];

let currentImageIndex = 0;

function loadBackgroundImage(index) {
    const imageArea = document.getElementById('image-area');
    if (!imageArea) {
        console.error('Error: image-area element not found!');
        return;
    }

    const imageIndex = (index !== undefined) ? index : currentImageIndex;
    const imageUrl = imageUrls[imageIndex];

    // imageArea.style.backgroundColor = '#ddd'; // Placeholder
    // imageArea.style.textAlign = 'center'; // From original
    // imageArea.innerHTML = '<p style="padding-top: 50px;">Loading image...</p>'; // From original, will be cleared by img.onload


    const img = new Image();
    img.onload = () => {
        console.log(`Background image ${imageIndex} loaded successfully: ${imageUrl}`);
        if (imageArea) {
            imageArea.innerHTML = ''; // Clear loading message
            imageArea.style.backgroundImage = `url('${imageUrl}')`;
        }
        displayTeachableObjects();
    };
    img.onerror = () => {
        console.error(`Error loading background image ${imageIndex}: ${imageUrl}. Check network or Unsplash status.`);
        if (imageArea) {
            // imageArea.style.backgroundImage = ''; // Keep it simple
            // imageArea.style.backgroundColor = '#eee';
            imageArea.innerHTML = '<p style="text-align:center; padding-top: 50px; color: #555;">Could not load image. Enjoy the words on a plain background!</p>';
        }
        displayTeachableObjects(); // Still display words even if image fails
    };
    img.src = imageUrl;
}

document.addEventListener('DOMContentLoaded', () => {
    loadBackgroundImage(currentImageIndex);
});

const teachableWords = [
    { word: "flower", type: "noun", iconUrl: "🌸" },
    { word: "circle", type: "shape", iconUrl: "https://via.placeholder.com/50/FF0000/FFFFFF?Text=Circle" },
    { word: "red", type: "color", iconUrl: "https://via.placeholder.com/50/FF0000/FFFFFF?Text=Red" }, // Placeholder, color itself is visual
    { word: "tree", type: "noun", iconUrl: "🌳" },
    { word: "square", type: "shape", iconUrl: "https://via.placeholder.com/50/00FF00/FFFFFF?Text=Square" },
    { word: "blue", type: "color", iconUrl: "https://via.placeholder.com/50/0000FF/FFFFFF?Text=Blue" }, // Placeholder
    { word: "sun", type: "noun", iconUrl: "☀️" },
    { word: "star", type: "shape", iconUrl: "⭐" },
    { word: "yellow", type: "color", iconUrl: "https://via.placeholder.com/50/FFFF00/000000?Text=Yellow" }, // Placeholder
    { word: "car", type: "noun", iconUrl: "🚗" },
    { word: "cat", type: "animal", iconUrl: "🐱" },
    { word: "dog", type: "animal", iconUrl: "🐶" },
    { word: "apple", type: "food", iconUrl: "🍎" },
    { word: "banana", type: "food", iconUrl: "🍌" },
    { word: "book", type: "object", iconUrl: "https://via.placeholder.com/50/A0522D/FFFFFF?Text=Book" },
    { word: "chair", type: "object", iconUrl: "https://via.placeholder.com/50/8B4513/FFFFFF?Text=Chair" },
    { word: "house", type: "place", iconUrl: "🏠" },
    { word: "ball", type: "toy", iconUrl: "⚽" },
    { word: "moon", type: "celestial", iconUrl: "🌙" },
    { word: "hat", type: "clothing", iconUrl: "https://via.placeholder.com/50/333333/FFFFFF?Text=Hat" }
];

const MAX_OBJECTS_ON_SCREEN = 3;

function loadNextImage() {
    currentImageIndex = (currentImageIndex + 1) % imageUrls.length;
    loadBackgroundImage(currentImageIndex);
}

function speakWord(word, element) {
    const imageArea = document.getElementById('image-area'); // Ensure imageArea is accessible
    if ('speechSynthesis' in window) {
        window.speechSynthesis.cancel();
        const utterance = new SpeechSynthesisUtterance(word);
        if (element) {
            element.classList.add('active');
        }
        utterance.onend = () => {
            if (element) {
                element.classList.remove('active');
                element.remove();
                if (imageArea) { // Check if imageArea is valid
                    const remainingObjects = imageArea.querySelectorAll('.teachable-object');
                    if (remainingObjects.length === 0) {
                        loadNextImage();
                    }
                }
            }
        };
        setTimeout(() => {
            // Check if element still exists and is active, as onend might have already handled it
            if (element && element.parentNode && element.classList.contains('active')) {
                element.classList.remove('active');
                element.remove();
                if (imageArea) { // Check if imageArea is valid
                    const remainingObjects = imageArea.querySelectorAll('.teachable-object');
                    if (remainingObjects.length === 0) {
                        loadNextImage();
                    }
                }
            }
        }, 2000);
        window.speechSynthesis.speak(utterance);
    } else {
        console.warn("Speech synthesis not supported in this browser.");
        alert("Sorry, your browser doesn't support the speech feature. Try Chrome or Firefox!");
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

    const wordsToDisplay = getRandomWords(teachableWords, MAX_OBJECTS_ON_SCREEN);

    wordsToDisplay.forEach(item => {
        const objectElement = document.createElement('div');
        objectElement.classList.add('teachable-object');
        objectElement.dataset.word = item.word; // Keep this for click functionality

        if (item.iconUrl) {
            const imgElement = document.createElement('img');
            imgElement.src = item.iconUrl;
            imgElement.alt = item.word; // For accessibility
            objectElement.appendChild(imgElement);
        } else {
            // Fallback if iconUrl is not defined (though it should be)
            objectElement.textContent = item.word;
        }

        // Ensure imageArea has dimensions before trying to place objects
        const areaWidth = imageArea.offsetWidth;
        const areaHeight = imageArea.offsetHeight;

        if (areaWidth > 0 && areaHeight > 0) {
            const maxX = areaWidth - 100; // 100 is object width guess
            const maxY = areaHeight - 40;  // 40 is object height guess
            objectElement.style.left = `${Math.random() * Math.max(0, maxX)}px`;
            objectElement.style.top = `${Math.random() * Math.max(0, maxY)}px`;
        } else {
            // Fallback if imageArea has no dimensions (e.g., display:none or not yet rendered)
            // This might happen if displayTeachableObjects is called too early or imageArea is hidden
            objectElement.style.left = `${Math.random() * 50 + 25}%`; // Percentage based as a rough fallback
            objectElement.style.top = `${Math.random() * 50 + 25}%`;
            console.warn("image-area has no dimensions, using percentage-based positioning for objects.");
        }

        objectElement.addEventListener('click', (event) => {
            const clickedWord = event.currentTarget.dataset.word;
            if (clickedWord) {
                speakWord(clickedWord, event.currentTarget);
            }
        });
        imageArea.appendChild(objectElement);
    });
}

function getRandomWords(wordsArray, count) {
    const shuffled = [...wordsArray].sort(() => 0.5 - Math.random());
    return shuffled.slice(0, count);
}

if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/service-worker.js')
      .then(registration => {
        console.log('ServiceWorker registration successful with scope: ', registration.scope);
      })
      .catch(error => {
        console.log('ServiceWorker registration failed: ', error);
      });
  });
}
