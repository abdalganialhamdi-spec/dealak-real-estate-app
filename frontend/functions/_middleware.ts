export async function onRequest(context: any) {
  const url = new URL(context.request.url);
  
  // Add CORS headers
  const response = await context.next();
  
  // Add security headers
  response.headers.set('X-Frame-Options', 'DENY');
  response.headers.set('X-Content-Type-Options', 'nosniff');
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
  
  return response;
}
