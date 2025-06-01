const CACHE_NAME = 'word-learner-cache-v1';
const urlsToCache = [
  '/', // Alias for index.html
  'index.html',
  'style.css',
  'script.js',
  // Add paths to any local icons if you have them, e.g., 'icons/icon-192x192.png'
  // For now, we'll assume icons are served or this list can be expanded later.
  'https://fonts.gstatic.com/s/lato/v16/S6uyw4BMUTPHjx4wWw.woff2' // Example of caching a Google Font if used
];

// Install event: Cache essential assets
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('Opened cache');
        return cache.addAll(urlsToCache);
      })
  );
});

// Activate event: Clean up old caches
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            console.log('Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  return self.clients.claim(); // Take control of uncontrolled clients
});

// Fetch event: Serve cached assets if available, otherwise fetch from network
self.addEventListener('fetch', event => {
  // We only want to cache GET requests for app assets, not Unsplash images or other external APIs.
  if (event.request.method === 'GET' && urlsToCache.includes(new URL(event.request.url).pathname.substring(1) ) || event.request.url === self.location.origin + '/') {
    event.respondWith(
      caches.match(event.request)
        .then(response => {
          // Cache hit - return response
          if (response) {
            return response;
          }
          // Not in cache - fetch from network
          return fetch(event.request).then(
            networkResponse => {
              // Check if we received a valid response
              if (!networkResponse || networkResponse.status !== 200 || networkResponse.type !== 'basic' && !urlsToCache.includes(event.request.url)) {
                return networkResponse;
              }

              // IMPORTANT: Clone the response. A response is a stream
              // and because we want the browser to consume the response
              // as well as the cache consuming the response, we need
              // to clone it so we have two streams.
              const responseToCache = networkResponse.clone();

              caches.open(CACHE_NAME)
                .then(cache => {
                  cache.put(event.request, responseToCache);
                });

              return networkResponse;
            }
          ).catch(error => {
            console.error('Fetching failed:', error);
            // Optionally, return an offline fallback page if available
            // if (event.request.mode === 'navigate') {
            //   return caches.match('offline.html');
            // }
          });
        })
    );
  } else {
    // For non-GET requests or requests not in urlsToCache (like Unsplash API calls),
    // just fetch from the network directly without caching.
    event.respondWith(fetch(event.request));
  }
});
