export async function cacheHTML(url) {
  const cache = await caches.open('html-cache');
  const response = await fetch(url);
  await cache.put(url, response.clone());
}

export async function getCachedHTML(url) {
  const cache = await caches.open('html-cache');
  const cachedResponse = await cache.match(url);
  if (cachedResponse) {
    return cachedResponse; // assuming the data is JSON
  }
  return null;
}
