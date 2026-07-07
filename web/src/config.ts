// The API lives on the same machine that serves the front, so derive its
// address from the page URL — works on localhost and from other devices
// on the LAN (http://192.168.x.x:5173).
const host = window.location.hostname;

export const API_URL = `http://${host}:3001`;
export const WS_URL = `ws://${host}:3001`;
