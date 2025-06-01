console.log("Word Learner Game script loaded!");

document.addEventListener('DOMContentLoaded', () => {
    const imageArea = document.getElementById('image-area');
    if (!imageArea) {
        console.error('Error: image-area element not found!');
        return;
    }

    imageArea.style.backgroundColor = '#ddd'; // Placeholder
    imageArea.style.textAlign = 'center';
    imageArea.innerHTML = '<p style="padding-top: 50px;">Loading image...</p>'; // Enabled loading message

    const imageUrl = `https://source.unsplash.com/random/800x600?nature,wallpaper,landscape`;

    const img = new Image();
    img.onload = () => {
        console.log('Background image loaded successfully.');
        imageArea.innerHTML = ''; // Clear loading message
        imageArea.style.backgroundImage = `url('${imageUrl}')`;
        displayTeachableObjects();
    };
    img.onerror = () => {
        console.error('Error loading background image. Check network or Unsplash status.');
        imageArea.style.backgroundImage = '';
        imageArea.style.backgroundColor = '#eee';
        // Clear loading message and set error message
        imageArea.innerHTML = '<p style="text-align:center; padding-top: 50px; color: #555;">Could not load image. Enjoy the words on a plain background!</p>';
        displayTeachableObjects();
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
    { word: "car", type: "noun" }
];

const MAX_OBJECTS_ON_SCREEN = 3;

function speakWord(word, element) { // Added element parameter
    if ('speechSynthesis' in window) {
        window.speechSynthesis.cancel();

        const utterance = new SpeechSynthesisUtterance(word);
        // utterance.lang = 'en-US'; // Optional

        if (element) {
            element.classList.add('active');
        }

        utterance.onend = () => {
            if (element) {
                element.classList.remove('active');
            }
        };

        // Fallback if onend doesn't fire reliably in all browsers for short words
        setTimeout(() => {
            if (element && element.classList.contains('active')) {
                element.classList.remove('active');
            }
        }, 2000); // Remove active class after 2 seconds regardless

        window.speechSynthesis.speak(utterance);
    } else {
        console.warn("Speech synthesis not supported in this browser.");
        alert("Sorry, your browser doesn't support the speech feature. Try Chrome or Firefox!");
    }
}

function displayTeachableObjects() {
    const imageArea = document.getElementById('image-area');
    if (!imageArea) return;

    // Clear previous objects but not the error/loading message if it's the only child
    const existingObjects = imageArea.querySelectorAll('.teachable-object');
    existingObjects.forEach(obj => obj.remove());

    const wordsToDisplay = getRandomWords(teachableWords, MAX_OBJECTS_ON_SCREEN);

    wordsToDisplay.forEach(item => {
        const objectElement = document.createElement('div');
        objectElement.classList.add('teachable-object');
        objectElement.textContent = item.word;
        objectElement.dataset.word = item.word;

        const maxX = imageArea.offsetWidth - 100;
        const maxY = imageArea.offsetHeight - 40;

        objectElement.style.left = `${Math.random() * Math.max(0, maxX)}px`;
        objectElement.style.top = `${Math.random() * Math.max(0, maxY)}px`;

        objectElement.addEventListener('click', (event) => {
            const clickedWord = event.currentTarget.dataset.word;
            if (clickedWord) {
                speakWord(clickedWord, event.currentTarget); // Pass element to speakWord
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
