console.log("Word Learner Game script loaded!");

document.addEventListener('DOMContentLoaded', () => {
    const imageArea = document.getElementById('image-area');
    if (!imageArea) {
        console.error('Error: image-area element not found!');
        return;
    }

    // imageArea.style.backgroundColor = '#ddd'; // Placeholder from original, can be kept or removed
    // imageArea.style.textAlign = 'center'; // From original
    // imageArea.innerHTML = '<p style="padding-top: 50px;">Loading image...</p>'; // From original, will be cleared by img.onload

    const imageUrl = `https://source.unsplash.com/800x600/?nature`; // As per previous subtask

    const img = new Image();
    img.onload = () => {
        console.log('Background image loaded successfully.');
        if (imageArea) { // Check if imageArea is still valid
            imageArea.innerHTML = ''; // Clear loading message
            imageArea.style.backgroundImage = `url('${imageUrl}')`;
        }
        displayTeachableObjects();
    };
    img.onerror = () => {
        console.error('Error loading background image. Check network or Unsplash status.');
        if (imageArea) { // Check if imageArea is still valid
            // imageArea.style.backgroundImage = ''; // Keep it simple
            // imageArea.style.backgroundColor = '#eee';
            imageArea.innerHTML = '<p style="text-align:center; padding-top: 50px; color: #555;">Could not load image. Enjoy the words on a plain background!</p>';
        }
        displayTeachableObjects(); // Still display words even if image fails
    };
    img.src = imageUrl;
});

const teachableWords = [
    { word: "flower", type: "noun" },
    { word: "circle", type: "shape" },
    { word: "red", type: "color" },
    { word: "tree", type: "noun" },
    { word: "square", type: "shape" },
    { word: "blue", type: "color" },
    { word: "sun", type: "noun" },
    { word: "star", type: "shape" },
    { word: "yellow", type: "color" },
    { word: "car", type: "noun" },
    { word: "cat", type: "animal" },
    { word: "dog", type: "animal" },
    { word: "apple", type: "food" },
    { word: "banana", type: "food" },
    { word: "book", type: "object" },
    { word: "chair", type: "object" },
    { word: "house", type: "place" },
    { word: "ball", type: "toy" },
    { word: "moon", type: "celestial" },
    { word: "hat", type: "clothing" }
];

const MAX_OBJECTS_ON_SCREEN = 3;

function speakWord(word, element) {
    if ('speechSynthesis' in window) {
        window.speechSynthesis.cancel();
        const utterance = new SpeechSynthesisUtterance(word);
        if (element) {
            element.classList.add('active');
        }
        utterance.onend = () => {
            if (element) {
                element.classList.remove('active');
                element.remove(); // Added line
            }
        };
        setTimeout(() => {
            if (element && element.classList.contains('active')) {
                element.classList.remove('active');
                element.remove(); // Added line
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
        objectElement.textContent = item.word;
        objectElement.dataset.word = item.word;

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
