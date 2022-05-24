addEventListener("fetch", (event) => {
  event.respondWith(handleRequest(event));
});

async function handleRequest(event) {
  const request = event.request;
  // Block all methods except GET and HEAD
  if (request.method === "GET" || request.method === "HEAD") {
    let response = await serveAsset(event);
    // Set error code if error
    if (response.status > 399) {
      response = new Response(
        "Error fetching resource from CDN: " + response.statusText,
        { status: response.status }
      );
    }
    return response;
  } else {
    return new Response(null, { status: 405 });
  }
}

async function serveAsset(event) {
  const request = event.request;
  const reqHead = request.headers;
  const url = new URL(request.url);
  // Remove the first trailing slash
  let item = new URL(request.url).pathname.replace(/\//, "");
  const fields = url.searchParams;
  const attach = fields.get("attach") == null ? "inline" : "attachment"; // 'attachment' if it exists, 'inline' otherwise

  // Preconditions
  // fetch param actually specified
  if (item === null) {
    return new Response(null, { status: 400 });
  }

  // Do fetch
  const fetchHeaders = new Headers({
    "User-Agent": "Cloudflare worker CDN-Serve/1.0.0",
  });
  if (reqHead.get("If-None-Match") !== null) {
    fetchHeaders.set("If-None-Match", reqHead.get("If-None-Match"));
  }
  if (reqHead.get("If-Modified-Since") !== null) {
    fetchHeaders.set("If-Modified-Since", reqHead.get("If-Modified-Since"));
  }
  if (reqHead.get("Range") !== null) {
    fetchHeaders.set("Range", reqHead.get("Range"));
  }

  const response = await fetch(
    `https://${BUCKET_NAME}.s3.${BUCKET_REGION}.amazonaws.com/${item}`,
    { headers: fetchHeaders }
  );

  // S3 returns a 403 Forbidden if not found, transform that into a 404 Not Found
  if (response.status == 403) {
    return new Response(null, { status: 404 });
  }

  const respHead = response.headers;
  const type = respHead.get("Content-Type") || "application/octet-stream"; // 'octet-stream' is a good default for unknown content
  const itemNameP = item.split("/"); // Split item name on path segments (extract raw name later)

  // Set headers
  const headers = new Headers({
    // Cache lifetime of 1 week
    "Cache-Control": `public, max-age=604800`,
    "Content-Type": type,
    "Content-Disposition": `${attach}; filename="${
      itemNameP[itemNameP.length - 1]
    }"`, // Just the file name, not any path before it
    ETag: respHead.get("ETag"),
    "Last-Modified": respHead.get("Last-Modified"),
    "CF-Cache-Status": respHead.get("CF-Cache-Status")
      ? respHead.get("CF-Cache-Status")
      : "UNKNOWN",
    Date: respHead.get("Date"),
    "Accept-Ranges": "bytes",
  });
  if (respHead.get("Age") !== null) {
    headers.set("Age", respHead.get("Age"));
  }
  if (response.status == 206) {
    headers.set("Content-Range", respHead.get("Content-Range"));
  }

  return new Response(response.body, { ...response, headers });
}
