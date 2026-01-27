#!/usr/bin/env bash
set -euo pipefail
if (set -o pipefail 2>/dev/null); then set -o pipefail; fi

# ================================================
# SSH BOT ELNENE PRO – INSTALADOR UNIFICADO (EMBED)
# Version: 8.8.27
# ================================================

BOT_VERSION="8.8.27"
BOT_NAME="ssh-bot"

INSTALL_DIR="/opt/ssh-bot"
BOT_HOME="/root/ssh-bot"
DB_FILE="$INSTALL_DIR/data/users.db"
CONFIG_FILE="$INSTALL_DIR/config/config.json"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo -e "${CYAN}${BOLD}"
cat << "BANNER"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     ███████╗███████╗██║  ██║    ██████╗  ██████╗ ████████╗  ║
║     ██╔════╝██╔════╝██║  ██║    ██╔══██╗██╔═══██╗╚══██╔══╝  ║
║     ███████╗███████╗███████║    ██████╔╝██║   ██║   ██║     ║
║     ╚════██║╚════██║██╔══██║    ██╔══██╗██║   ██║   ██║     ║
║     ███████║███████║██║  ██║    ██████╔╝╚██████╔╝   ██║     ║
║     ╚══════╝╚══════╝╚═╝  ╚═╝    ╚═════╝  ╚═════╝    ╚═╝     ║
║                                                              ║
║        🚀 SSH BOT ELNENE PRO – v8.8.27 (EMBED)              ║
║        🤖 Bot WhatsApp + panel admin PRO                     ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"

if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}${BOLD}❌ Debes ejecutar como root${NC}"
  exit 1
fi

echo -e "${CYAN}${BOLD}🔍 Detectando IP pública...${NC}"
SERVER_IP="$(curl -4 -s --max-time 10 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')"
if [[ -z "${SERVER_IP}" ]]; then
  read -rp "📝 Ingresa IP del servidor: " SERVER_IP
fi
echo -e "${GREEN}✅ IP detectada: ${CYAN}${SERVER_IP}${NC}\n"

echo -e "${YELLOW}⚠️  ESTE INSTALADOR INSTALA:${NC}"
echo -e "   ✅ 🤖 Bot WhatsApp + panel admin PRO"
echo -e "   ✅ 💳 MercadoPago integrado (token editable desde panel)"
echo -e "   ✅ 💲 Precios editables 7/15/30 desde panel"
echo -e "   ✅ 🧩 Selector de app en compra: APK / HC(HWID) / Token-Only"
echo -e "   ✅ 🆔 HWID: user+pass = HWID + envío de <HWID>.hc"
echo -e "   ✅ 🔑 Token-Only: genera y gestiona tokens (revocar/listar)"
echo -e "   ✅ 📲 Gestión APK (subir/borrar/listar)"
echo -e "   ✅ 👥 Gestión usuarios: eliminar / eliminar expirados / conectados"
echo -e "   ✅ 📊 Estadísticas: ventas + ganancias"
echo -e "   ✅ 🔄 Auto-refresh PM2 cada 2 horas + Update desde panel (anti-cuelgue)"
echo -e "   ✅ 🧠 IA Gemini (opcional): soporte automático + fallback al menú"
echo -e "   ✅ 🧾 Menú cliente restaurado: responde a \"menu\" (y detecta textos mal escritos)"
echo -e "   ✅ 📲 APK: importar desde /root + descargar por URL (ambas opciones)"
echo -e "   ✅ 🌐 Custom/HTTP: mensaje + URL editables desde panel (para el cliente)"
echo -e "   ✅ 🆘 Soporte/Tutorial: WhatsApp + Telegram + links editables desde panel"
echo -e "   ✅ 📱 QR FIX: Vincular WhatsApp desde panel (TXT/PNG)"
echo
read -rp "$(echo -e "${YELLOW}¿Continuar? (s/N): ${NC}")" -n 1 -r
echo
[[ ! $REPLY =~ ^[Ss]$ ]] && { echo "Cancelado."; exit 0; }

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq

apt-get install -y -qq \
  curl wget git unzip \
  sqlite3 jq nano htop \
  cron build-essential \
  ca-certificates gnupg \
  software-properties-common \
  libgbm-dev libxshmfence-dev \
  sshpass at >/dev/null 2>&1 || true

# Extras (no romper si no existen en el repo)
apt-get install -y -qq qrencode chafa >/dev/null 2>&1 || true
if apt-cache show viu >/dev/null 2>&1; then
  apt-get install -y -qq viu >/dev/null 2>&1 || true
fi

systemctl enable atd >/dev/null 2>&1 || true
systemctl start atd >/dev/null 2>&1 || true
systemctl enable cron >/dev/null 2>&1 || true
systemctl restart cron >/dev/null 2>&1 || true

if ! command -v google-chrome >/dev/null 2>&1; then
  echo -e "${CYAN}${BOLD}🌐 Instalando Google Chrome...${NC}"
  wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
  apt-get install -y /tmp/chrome.deb >/dev/null 2>&1 || true
  rm -f /tmp/chrome.deb
fi

if ! command -v node >/dev/null 2>&1; then
  echo -e "${CYAN}${BOLD}🟢 Instalando NodeJS 20...${NC}"
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash - >/dev/null 2>&1 || true
  apt-get install -y nodejs >/dev/null 2>&1 || true
fi

npm install -g pm2 --silent >/dev/null 2>&1 || true

mkdir -p "$INSTALL_DIR"/{data,config,qr_codes,logs,backups}
mkdir -p "$BOT_HOME"/{config,data,apks,hc,logs}
chmod -R 755 "$INSTALL_DIR" >/dev/null 2>&1 || true
chmod -R 700 "$INSTALL_DIR/config" >/dev/null 2>&1 || true

if [[ ! -s "$CONFIG_FILE" ]]; then
  cat > "$CONFIG_FILE" <<EOF
{
  "bot": { "name": "SSH BOT ELNENE PRO", "version": "8.8.27", "server_ip": "${SERVER_IP}" },
  "admins": [],
  "prices": { "test_hours": 2, "plan_7": 500, "plan_15": 800, "plan_30": 1200, "currency": "ARS" },
  "mercadopago": { "access_token": "", "enabled": false },
  "gemini": { "enabled": false, "api_key": "" },
  "links": {
    "tutorial": "https://youtube.com",
    "support": "https://t.me/soporte",
    "support_whatsapp": "",
    "telegram": ""
  },
  "downloads": {
    "apk_url": "",
    "custom_url": "",
    "custom_message": "📲 *HTTP Custom*\n\n⬇️ Descargá desde:\n{URL}\n\nLuego importá tu archivo .hc (HWID) y conectá."
  }
}
EOF
  chmod 600 "$CONFIG_FILE" >/dev/null 2>&1 || true
fi
cp -f "$CONFIG_FILE" "$BOT_HOME/config/config.json" >/dev/null 2>&1 || true

# DB
sqlite3 "$DB_FILE" <<'SQL'
CREATE TABLE IF NOT EXISTS users (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 phone TEXT,
 username TEXT UNIQUE,
 password TEXT,
 tipo TEXT,
 expires_at DATETIME,
 max_connections INTEGER DEFAULT 1,
 status INTEGER DEFAULT 1,
 created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
 app_type TEXT DEFAULT '',
 hwid TEXT DEFAULT ''
);
CREATE TABLE IF NOT EXISTS tokens (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 phone TEXT,
 token TEXT UNIQUE,
 plan TEXT,
 expires_at TEXT,
 status TEXT DEFAULT 'active',
 created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS payments (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 phone TEXT,
 external_reference TEXT UNIQUE,
 preference_id TEXT,
 amount REAL,
 currency TEXT,
 status TEXT DEFAULT 'pending',
 plan TEXT,
 app_type TEXT,
 created_at TEXT DEFAULT CURRENT_TIMESTAMP,
 approved_at TEXT
);
SQL

echo -e "${CYAN}${BOLD}🤖 Instalando bot.js (embebido)...${NC}"
cat > "$BOT_HOME/bot.js" <<'BOTJS'
#!/usr/bin/env node
/**
 * SSH BOT ELNENE PRO – bot.js (embedded)
 * Version: 8.8.27
 * Features:
 *  - WhatsApp connection via whatsapp-web.js (LocalAuth)
 *  - Saves QR to /root/qr-whatsapp.txt and /root/qr-whatsapp.png
 *  - MercadoPago preference creation (optional)
 *  - Minimal purchase flow + user/token generation persisted in SQLite
 *
 * NOTE: This is a self-contained bot implementation meant to be installed by the unified installer.
 */

"use strict";

const fs = require("fs");
const path = require("path");
const os = require("os");
const { execSync } = require("child_process");

const sqlite3 = require("sqlite3").verbose();
const axios = require("axios").default;

const qrcode = require("qrcode");
const qrcodeTerminal = require("qrcode-terminal");

const { Client, LocalAuth, MessageMedia } = require("whatsapp-web.js");

const ROOT = "/root";
const INSTALL_DIR = "/opt/ssh-bot";
const BOT_HOME = "/root/ssh-bot";
const DB_FILE = path.join(INSTALL_DIR, "data", "users.db");

const QR_TXT = path.join(ROOT, "qr-whatsapp.txt");
const QR_PNG = path.join(ROOT, "qr-whatsapp.png");

const CONFIG_CANDIDATES = [
  path.join(BOT_HOME, "config", "config.json"),
  path.join(INSTALL_DIR, "config", "config.json"),
  path.join(BOT_HOME, "config.json"),
];

function readJsonSafe(p) {
  try { return JSON.parse(fs.readFileSync(p, "utf8")); } catch { return null; }
}

function loadConfig() {
  for (const p of CONFIG_CANDIDATES) {
    const j = readJsonSafe(p);
    if (j) return { config: j, path: p };
  }
  return { config: {}, path: "" };
}

let { config, path: configPath } = loadConfig();

function reloadConfig() {
  const r = loadConfig();
  config = r.config || {};
  configPath = r.path || configPath;
}

function cfg(pathExpr, fallback) {
  try {
    // simple dot-notation getter
    const parts = pathExpr.split(".");
    let cur = config;
    for (const k of parts) {
      if (cur && Object.prototype.hasOwnProperty.call(cur, k)) cur = cur[k];
      else return fallback;
    }
    return (cur === undefined || cur === null) ? fallback : cur;
  } catch {
    return fallback;
  }
}

const BOT_NAME = cfg("bot.name", "SSH BOT ELNENE PRO");
const BOT_VERSION = cfg("bot.version", "8.8.27");

const MP_TOKEN = cfg("mercadopago.access_token", "");
const MP_ENABLED = !!MP_TOKEN && cfg("mercadopago.enabled", false) !== false;

const TEST_HOURS = Number(cfg("prices.test_hours", 2));
const PRICE_7 = Number(cfg("prices.plan_7", 0));
const PRICE_15 = Number(cfg("prices.plan_15", 0));
const PRICE_30 = Number(cfg("prices.plan_30", 0));
const CURRENCY = cfg("prices.currency", "ARS");

function linksCfg() {
  return {
    support: cfg("links.support", "https://t.me/soporte"),
    support_whatsapp: cfg("links.support_whatsapp", ""),
    telegram: cfg("links.telegram", ""),
    tutorial: cfg("links.tutorial", "https://youtube.com"),
  };
}

function downloadsCfg() {
  return {
    apk_url: cfg("downloads.apk_url", ""),
    custom_url: cfg("downloads.custom_url", ""),
    custom_message: cfg("downloads.custom_message", "📲 *HTTP Custom*\n\n⬇️ Descargá desde:\n{URL}\n\nLuego importá tu archivo .hc (HWID) y conectá."),
  };
}

function geminiCfg() {
  return {
    enabled: !!cfg("gemini.enabled", false),
    api_key: cfg("gemini.api_key", ""),
  };
}

async function geminiSupportReply(userText) {
  try {
    const g = geminiCfg();
    if (!g.enabled || !g.api_key) return null;
    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${g.api_key}`;
    const payload = {
      contents: [{
        parts: [{
          text:
`Eres soporte técnico de un servicio SSH/VPN.
Responde claro, profesional y breve.
Ayuda a diagnosticar errores comunes de conexión.
Usa emojis moderados.
Si el usuario pide el menú, decile que escriba "menu".

Consulta del usuario:
"${userText}"`
        }]
      }]
    };
    const resp = await axios.post(url, payload, { timeout: 15000 });
    const out = resp?.data?.candidates?.[0]?.content?.parts?.[0]?.text;
    return out ? String(out).trim() : null;
  } catch (e) {
    log(`Gemini error: ${e.message}`);
    return null;
  }
}

function menuText() {
  return `🤖 *${BOT_NAME}* (${BOT_VERSION})\n\n` +
    `1️⃣ 🆓 Prueba GRATIS (${TEST_HOURS}h)\n` +
    `2️⃣ 💳 Planes Premium (7/15/30)\n` +
    `3️⃣ 👤 Mis cuentas\n` +
    `4️⃣ 💳 Estado de pago\n` +
    `5️⃣ 📲 Descargar app / Custom\n` +
    `6️⃣ 🆘 Soporte\n\n` +
    `💬 Responde con el número o escribí *comprar* para comprar.`;
}

function premiumMenuText() {
  return `💎 *PLANES PREMIUM*\n\n` +
    `1️⃣ 7 días  - $${PRICE_7} ${CURRENCY}\n` +
    `2️⃣ 15 días - $${PRICE_15} ${CURRENCY}\n` +
    `3️⃣ 30 días - $${PRICE_30} ${CURRENCY}\n\n` +
    `💬 Responde 1/2/3`;
}

function supportText() {
  const l = linksCfg();
  const parts = [];
  if (l.support_whatsapp) parts.push(`📱 WhatsApp: ${l.support_whatsapp}`);
  if (l.telegram) parts.push(`✈️ Telegram: ${l.telegram}`);
  if (l.support) parts.push(`🔗 Soporte: ${l.support}`);
  if (l.tutorial) parts.push(`📺 Tutorial: ${l.tutorial}`);
  return `🆘 *SOPORTE*\n\n${parts.join("\n")}\n\n💬 Si querés, escribí tu problema y te responde la IA (si está activada).`;
}

function customDownloadText() {
  const d = downloadsCfg();
  const url = d.custom_url || "(sin URL configurada)";
  const msg = (d.custom_message || "").replace(/\{URL\}/g, url);
  return msg;
}

const ADMIN_NUMBERS = (cfg("admins", []) || [])
  .map(s => String(s).replace(/\D/g, ""))
  .filter(Boolean);

function nowIso() {
  return new Date().toISOString().replace("T", " ").replace("Z", "");
}

function addHours(date, h) {
  return new Date(date.getTime() + h * 3600 * 1000);
}
function addDays(date, d) {
  return new Date(date.getTime() + d * 24 * 3600 * 1000);
}

function randStr(n) {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789";
  let s = "";
  for (let i = 0; i < n; i++) s += chars[Math.floor(Math.random() * chars.length)];
  return s;
}

function normalizeNumber(from) {
  // from: "54911....@c.us"
  const num = String(from).split("@")[0].replace(/\D/g, "");
  return num;
}

function isAdminNumber(num) {
  if (!ADMIN_NUMBERS.length) return true; // if not configured, allow
  return ADMIN_NUMBERS.includes(num);
}

function log(msg) {
  const line = `[${new Date().toISOString()}] ${msg}`;
  console.log(line);
  try { fs.appendFileSync(path.join(INSTALL_DIR, "logs", "bot.log"), line + "\n"); } catch {}
}

function ensureDb() {
  fs.mkdirSync(path.dirname(DB_FILE), { recursive: true });
  const db = new sqlite3.Database(DB_FILE);
  db.serialize(() => {
    db.run(`CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      phone TEXT,
      username TEXT UNIQUE,
      password TEXT,
      tipo TEXT,
      expires_at DATETIME,
      max_connections INTEGER DEFAULT 1,
      status INTEGER DEFAULT 1,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      app_type TEXT DEFAULT '',
      hwid TEXT DEFAULT ''
    );`);
    db.run(`CREATE TABLE IF NOT EXISTS tokens (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      phone TEXT,
      token TEXT UNIQUE,
      plan TEXT,
      expires_at TEXT,
      status TEXT DEFAULT 'active',
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );`);
    db.run(`CREATE TABLE IF NOT EXISTS payments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      phone TEXT,
      external_reference TEXT UNIQUE,
      preference_id TEXT,
      amount REAL,
      currency TEXT,
      status TEXT DEFAULT 'pending',
      plan TEXT,
      app_type TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      approved_at TEXT
    );`);
  });
  return db;
}

const db = ensureDb();

function dbGet(sql, params=[]) {
  return new Promise((resolve, reject) => {
    db.get(sql, params, (err, row) => err ? reject(err) : resolve(row));
  });
}
function dbAll(sql, params=[]) {
  return new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => err ? reject(err) : resolve(rows));
  });
}
function dbRun(sql, params=[]) {
  return new Promise((resolve, reject) => {
    db.run(sql, params, function(err) {
      if (err) reject(err);
      else resolve({ lastID: this.lastID, changes: this.changes });
    });
  });
}

/**
 * Create a Linux system user for SSH
 */
function createLinuxUser(username, password) {
  // Best-effort, assumes running as root
  execSync(`id -u ${username} >/dev/null 2>&1 || useradd -m -s /bin/bash ${username}`, { stdio: "ignore" });
  execSync(`echo "${username}:${password}" | chpasswd`, { stdio: "ignore" });
}

function setLinuxExpire(username, expiresAt) {
  if (!expiresAt) return;
  // expiresAt format "YYYY-MM-DD HH:MM:SS" (UTC-ish). We'll convert to YYYY-MM-DD.
  const date = String(expiresAt).split(" ")[0];
  execSync(`chage -E "${date}" "${username}" >/dev/null 2>&1 || true`, { stdio: "ignore" });
}

function deleteLinuxUser(username) {
  execSync(`id -u ${username} >/dev/null 2>&1 && userdel -r ${username} >/dev/null 2>&1 || true`, { stdio: "ignore" });
}

function makeCredentials() {
  const username = ("u" + randStr(7)).toLowerCase();
  const password = randStr(10);
  return { username, password };
}

function computeExpiry(plan) {
  const base = new Date();
  if (plan === "test") return addHours(base, TEST_HOURS);
  if (plan === "7") return addDays(base, 7);
  if (plan === "15") return addDays(base, 15);
  if (plan === "30") return addDays(base, 30);
  return null;
}

function fmtDate(d) {
  if (!d) return "";
  const yyyy = d.getUTCFullYear();
  const mm = String(d.getUTCMonth()+1).padStart(2,"0");
  const dd = String(d.getUTCDate()).padStart(2,"0");
  const hh = String(d.getUTCHours()).padStart(2,"0");
  const mi = String(d.getUTCMinutes()).padStart(2,"0");
  const ss = String(d.getUTCSeconds()).padStart(2,"0");
  return `${yyyy}-${mm}-${dd} ${hh}:${mi}:${ss}`;
}

function planPrice(plan) {
  if (plan === "test") return 0;
  if (plan === "7") return PRICE_7;
  if (plan === "15") return PRICE_15;
  if (plan === "30") return PRICE_30;
  return 0;
}

function planLabel(plan) {
  if (plan === "test") return `Test ${TEST_HOURS}h`;
  if (plan === "7") return "7 días";
  if (plan === "15") return "15 días";
  if (plan === "30") return "30 días";
  return plan;
}

function appLabel(app) {
  if (app === "apk") return "APK";
  if (app === "hc") return "HC(HWID)";
  if (app === "token") return "Token-Only";
  return app || "";
}

async function createDbUser(phone, plan, appType, hwid="", maxConn=1) {
  const { username, password } = makeCredentials();
  const exp = computeExpiry(plan);
  const expires_at = exp ? fmtDate(exp) : null;

  // db first to ensure uniqueness; if collision, retry
  for (let i=0; i<5; i++) {
    try {
      await dbRun(
        "INSERT INTO users(phone, username, password, tipo, expires_at, max_connections, status, app_type, hwid) VALUES(?,?,?,?,?,?,1,?,?)",
        [phone, username, password, plan === "test" ? "test" : "premium", expires_at, (maxConn||1), appType || "", hwid || ""]
      );
      // system user
      createLinuxUser(username, password);
      if (expires_at) setLinuxExpire(username, expires_at);
      return { username, password, expires_at };
    } catch (e) {
      if (String(e).includes("UNIQUE")) continue;
      throw e;
    }
  }
  throw new Error("No pude generar username único.");
}

async function createToken(phone, plan, daysOrNull) {
  const token = "TKN_" + randStr(20);
  const exp = daysOrNull ? fmtDate(addDays(new Date(), daysOrNull)) : null;
  await dbRun(
    "INSERT INTO tokens(phone, token, plan, expires_at, status) VALUES(?,?,?,?, 'active')",
    [phone, token, plan, exp]
  );
  return { token, expires_at: exp };
}

async function mpCreatePreference({ phone, plan, appType }) {
  const amount = planPrice(plan);
  if (!MP_ENABLED) throw new Error("MercadoPago no está configurado.");

  const external_reference = `SSH-${phone}-${Date.now()}-${randStr(4)}`;

  // Create preference via API (simpler & avoids SDK incompatibilities)
  const body = {
    items: [
      {
        title: `${BOT_NAME} – ${planLabel(plan)} – ${appLabel(appType)}`,
        quantity: 1,
        currency_id: CURRENCY,
        unit_price: Number(amount || 0)
      }
    ],
    external_reference,
    expires: true,
    // expiration_date_from / to can be added if needed
  };

  const resp = await axios.post(
    "https://api.mercadopago.com/checkout/preferences",
    body,
    { headers: { Authorization: `Bearer ${MP_TOKEN}` }, timeout: 15000 }
  );

  const pref = resp.data;
  await dbRun(
    "INSERT OR IGNORE INTO payments(phone, external_reference, preference_id, amount, currency, status, plan, app_type) VALUES(?,?,?,?,?, 'pending', ?, ?)",
    [phone, external_reference, pref.id, amount, CURRENCY, plan, appType]
  );

  return { init_point: pref.init_point, preference_id: pref.id, external_reference };
}

async function mpCheckApproved(external_reference) {
  if (!MP_ENABLED) return { approved: false, reason: "MP no configurado" };

  // Search payments by external_reference
  const url = `https://api.mercadopago.com/v1/payments/search?external_reference=${encodeURIComponent(external_reference)}`;
  const resp = await axios.get(url, { headers: { Authorization: `Bearer ${MP_TOKEN}` }, timeout: 15000 });
  const results = resp.data && resp.data.results ? resp.data.results : [];
  // Pick latest
  results.sort((a,b) => (b.date_created || "").localeCompare(a.date_created || ""));
  const pay = results[0];
  if (!pay) return { approved: false, reason: "Sin pagos encontrados aún" };
  if (pay.status === "approved") return { approved: true, payment: pay };
  return { approved: false, reason: `Estado: ${pay.status}` };
}

const sessions = new Map(); // phone -> session state

function sessionGet(phone) {
  if (!sessions.has(phone)) sessions.set(phone, { step: "idle" });
  return sessions.get(phone);
}

function resetSession(phone) {
  sessions.set(phone, { step: "idle" });
}

function helpText(isAdmin) {
  const base =
`🤖 *${BOT_NAME}* (v${BOT_VERSION})

🛒 Para comprar:
1) Escribí: *comprar*
2) Elegí plan y tipo de app
3) Pagás y luego enviás: *verificar <REF>* (te la da el bot)

📌 Comandos:
• *comprar* – iniciar compra
• *precios* – ver precios
• *ayuda* – ver ayuda
`;

  const admin =
`
👑 Admin:
• *admin usuarios* – listar usuarios
• *admin borrar <user>* – borrar usuario
• *admin tokens* – listar tokens
• *admin revocar <token>* – revocar token
`;

  return base + (isAdmin ? admin : "");
}

function pricesText() {
  return `💲 *Precios* (${CURRENCY})
• Test ${TEST_HOURS}h: $0
• 7 días: $${PRICE_7}
• 15 días: $${PRICE_15}
• 30 días: $${PRICE_30}`;
}

function buyMenuText() {
  return `🧩 *Elegí un PLAN* respondiendo con el número:

1) Test ${TEST_HOURS}h
2) 7 días
3) 15 días
4) 30 días

(Respondé: 1/2/3/4)`;
}

function appMenuText() {
  return `📱 *Elegí tipo de app*:

1) APK
2) HC (HWID)
3) Token-Only

(Respondé: 1/2/3)`;
}

function mapPlanChoice(c) {
  if (c === "1") return "test";
  if (c === "2") return "7";
  if (c === "3") return "15";
  if (c === "4") return "30";
  return null;
}
function mapAppChoice(c) {
  if (c === "1") return "apk";
  if (c === "2") return "hc";
  if (c === "3") return "token";
  return null;
}

async function handleAdminCommand(client, msg, phone, text) {
  const parts = text.trim().split(/\s+/);
  const sub = (parts[1] || "").toLowerCase();

  if (sub === "usuarios") {
    const rows = await dbAll("SELECT username,tipo,expires_at,app_type FROM users ORDER BY id DESC LIMIT 50");
    if (!rows.length) return client.sendMessage(msg.from, "No hay usuarios.");
    const lines = rows.map(r => `• ${r.username} | ${r.tipo} | exp: ${r.expires_at || "∞"} | ${r.app_type || "-"}`);
    return client.sendMessage(msg.from, "*Usuarios (últimos 50)*\n" + lines.join("\n"));
  }

  if (sub === "borrar" && parts[2]) {
    const u = parts[2];
    const row = await dbGet("SELECT username FROM users WHERE username=?", [u]);
    if (!row) return client.sendMessage(msg.from, "No existe ese usuario.");
    await dbRun("DELETE FROM users WHERE username=?", [u]);
    try { deleteLinuxUser(u); } catch {}
    return client.sendMessage(msg.from, `✅ Usuario borrado: ${u}`);
  }

  if (sub === "tokens") {
    const rows = await dbAll("SELECT token,plan,expires_at,status FROM tokens ORDER BY id DESC LIMIT 50");
    if (!rows.length) return client.sendMessage(msg.from, "No hay tokens.");
    const lines = rows.map(r => `• ${r.token} | ${r.plan} | exp: ${r.expires_at || "∞"} | ${r.status}`);
    return client.sendMessage(msg.from, "*Tokens (últimos 50)*\n" + lines.join("\n"));
  }

  if (sub === "revocar" && parts[2]) {
    const t = parts[2];
    await dbRun("UPDATE tokens SET status='revoked' WHERE token=?", [t]);
    return client.sendMessage(msg.from, `✅ Token revocado: ${t}`);
  }

  return client.sendMessage(msg.from, "Admin: comandos: admin usuarios | admin borrar <user> | admin tokens | admin revocar <token>");
}

async function handleMessage(client, msg) {
  const phone = normalizeNumber(msg.from);
  const text = (msg.body || "").trim();
  const lower = text.toLowerCase();
  const isAdmin = isAdminNumber(phone);


  // Reload config (so panel edits apply without reinstall; restart still recommended)
  reloadConfig();

  // Quick menu
  if (lower === "menu" || lower === "start" || lower === "inicio" || lower === "hola" || lower === "hi") {
    resetSession(phone);
    return client.sendMessage(msg.from, menuText());
  }

  // Session handling
  const s = sessionGet(phone);

  // Menu numeric shortcuts (when not already in flow)
  if (!s.step || s.step === "idle") {
    if (lower === "1") { s.step = "choose_app"; s.plan = "test"; s.app = null; return client.sendMessage(msg.from, appMenuText()); }
    if (lower === "2") { s.step = "choose_premium_plan"; s.plan = null; s.app = null; return client.sendMessage(msg.from, premiumMenuText()); }
    if (lower === "3") {
      const rows = await dbAll("SELECT username, password, tipo, expires_at, app_type, hwid FROM users WHERE phone=? ORDER BY id DESC LIMIT 5", [phone]);
      const toks = await dbAll("SELECT token, plan, expires_at, status FROM tokens WHERE phone=? ORDER BY id DESC LIMIT 5", [phone]);
      if ((!rows || rows.length===0) && (!toks || toks.length===0)) {
        return client.sendMessage(msg.from, "📭 No tenés cuentas registradas.\n\nEscribí *menu* o *comprar*.");
      }
      let out = "👤 *MIS CUENTAS*\n\n";
      if (rows && rows.length) {
        for (const r of rows) {
          out += `✅ Usuario: *${r.username}*\n🔐 Pass: *${r.password}*\n📦 Tipo: *${r.tipo || ""}*\n📅 Expira: *${r.expires_at || "∞"}*\n🧩 App: *${r.app_type || "-"}*\n`;
          if (r.hwid) out += `🆔 HWID: *${r.hwid}*\n`;
          out += "----------------------\n";
        }
      }
      if (toks && toks.length) {
        out += "\n🔑 *TOKENS*\n";
        for (const t of toks) {
          out += `• ${t.token}  (${t.plan})  expira: ${t.expires_at || "∞"}  [${t.status}]\n`;
        }
      }
      return client.sendMessage(msg.from, out);
    }
    if (lower === "4") {
      const pays = await dbAll("SELECT external_reference, status, plan, app_type, amount, currency, created_at FROM payments WHERE phone=? ORDER BY id DESC LIMIT 5", [phone]);
      if (!pays || !pays.length) return client.sendMessage(msg.from, "💳 No tengo pagos registrados.\n\nEscribí *comprar* para generar uno.");
      let out = "💳 *ESTADO DE PAGOS*\n\n";
      for (const p of pays) {
        out += `${p.status === "approved" ? "✅" : "⏳"} *${p.status.toUpperCase()}*\n`;
        out += `Plan: ${p.plan || "-"} | Tipo: ${p.app_type || "-"} | $${p.amount || 0} ${p.currency || CURRENCY}\n`;
        out += `Ref: ${p.external_reference}\n`;
        out += `Fecha: ${p.created_at || ""}\n`;
        out += "----------------------\n";
      }
      out += `\n🔎 Para verificar manual: *verificar <REF>*`;
      return client.sendMessage(msg.from, out);
    }
    if (lower === "5") {
      // APK / Custom download info
      const d = downloadsCfg();
      let out = "📲 *DESCARGAS*\n\n";
      // Try send latest APK in BOT_HOME/apks
      try {
        const apkDir = path.join(BOT_HOME, "apks");
        const files = fs.existsSync(apkDir) ? fs.readdirSync(apkDir).filter(f=>f.toLowerCase().endsWith(".apk")) : [];
        if (files.length) {
          files.sort((a,b)=>fs.statSync(path.join(apkDir,b)).mtimeMs - fs.statSync(path.join(apkDir,a)).mtimeMs);
          const fp = path.join(apkDir, files[0]);
          const st = fs.statSync(fp);
          out += `✅ APK disponible: *${files[0]}* (${(st.size/1024/1024).toFixed(2)} MB)\n`;
          out += "Si WhatsApp permite, te la envío ahora...\n";
          const media = MessageMedia.fromFilePath(fp);
          await client.sendMessage(msg.from, media, { caption: `📲 APK: ${files[0]}` });
          return;
        }
      } catch (_) {}
      if (d.apk_url) out += `🔗 APK URL: ${d.apk_url}\n\n`;
      out += `🧩 *HTTP Custom*\n${customDownloadText()}\n`;
      return client.sendMessage(msg.from, out);
    }
    if (lower === "6" || lower === "soporte") {
      return client.sendMessage(msg.from, supportText());
    }
  }

  if (lower === "ayuda" || lower === "help" || lower === "!help" || lower === "/help") {
    return client.sendMessage(msg.from, helpText(isAdmin));
  }
  if (lower === "precios" || lower === "!precios") {
    return client.sendMessage(msg.from, pricesText());
  }

  if (lower.startsWith("admin ")) {
    if (!isAdmin) return client.sendMessage(msg.from, "❌ No autorizado.");
    return handleAdminCommand(client, msg, phone, text);
  }

  // Verify payment: "verificar <REF>"
  if (lower.startsWith("verificar")) {
    const ref = text.split(/\s+/)[1];
    if (!ref) return client.sendMessage(msg.from, "Usá: verificar <REF>");
    const row = await dbGet("SELECT status, plan, app_type, phone FROM payments WHERE external_reference=?", [ref]);
    if (!row) return client.sendMessage(msg.from, "No encuentro esa referencia.");
    if (row.status === "approved") return client.sendMessage(msg.from, "✅ Ya estaba aprobado. Si no recibiste acceso, avisá al admin.");

    const chk = await mpCheckApproved(ref);
    if (!chk.approved) return client.sendMessage(msg.from, `⏳ Aún no aprobado. ${chk.reason}`);

    await dbRun("UPDATE payments SET status='approved', approved_at=? WHERE external_reference=?", [nowIso(), ref]);

    const appType = row.app_type || "apk";
    const plan = row.plan || "7";

    if (appType === "token") {
      const days = plan === "7" ? 7 : plan === "15" ? 15 : plan === "30" ? 30 : 1;
      const t = await createToken(phone, plan, days);
      return client.sendMessage(msg.from,
        `✅ Pago aprobado.\n🔑 *Token*: ${t.token}\n📅 Expira: ${t.expires_at || "∞"}\n\n📌 Escribí *menu* para ver opciones.`
      );
    }

    const u = await createDbUser(phone, plan, appType);
    let extra = "";
    if (appType === "apk") {
      const d = downloadsCfg();
      if (d.apk_url) extra = "\n\n📲 Descarga APK: " + d.apk_url;
      else extra = "\n\n📲 Escribí *5* para descargar la app.";
    }
    if (appType === "hc") {
      extra = "\n🆔 Enviá tu *HWID* para activar (formato texto).\n\n" + customDownloadText();
    }
    return client.sendMessage(msg.from,
      `✅ Pago aprobado.\n👤 *Usuario*: ${u.username}\n🔐 *Pass*: ${u.password}\n📅 Expira: ${u.expires_at || "∞"}${extra}`
    );
  }

  // HWID message: "hwid <value>"
  if (lower.startsWith("hwid")) {
    const hwid = text.split(/\s+/).slice(1).join(" ").trim();
    if (!hwid) return client.sendMessage(msg.from, "Usá: hwid <TU_HARDWARE_ID>");
    // attach hwid to latest active user for this phone
    const row = await dbGet("SELECT username FROM users WHERE phone=? ORDER BY id DESC LIMIT 1", [phone]);
    if (!row) return client.sendMessage(msg.from, "No tengo un usuario asociado todavía.");
    await dbRun("UPDATE users SET hwid=? WHERE username=?", [hwid, row.username]);

    // also write .hc file for pickup
    try {
      const hcDir = path.join(BOT_HOME, "hc");
      fs.mkdirSync(hcDir, { recursive: true });
      const fp = path.join(hcDir, `${hwid}.hc`);
      fs.writeFileSync(fp, `HWID=${hwid}\nUSER=${row.username}\n`, "utf8");
    } catch {}

    return client.sendMessage(msg.from, `✅ HWID guardado para ${row.username}.`);
  }

  // Start purchase
  if (lower === "comprar" || lower === "!comprar" || lower === "/comprar") {
    const s = sessionGet(phone);
    s.step = "choose_plan";
    s.plan = null;
    s.app = null;
    return client.sendMessage(msg.from, buyMenuText());
  }

  if (s.step === "choose_premium_plan") {
    const v = String(text).trim();
    let plan = null;
    if (v === "1") plan = "7";
    else if (v === "2") plan = "15";
    else if (v === "3") plan = "30";
    if (!plan) return client.sendMessage(msg.from, "Elegí: 1/2/3");
    s.plan = plan;
    s.step = "choose_app";
    return client.sendMessage(msg.from, appMenuText());
  }

  if (s.step === "choose_plan") {
    const plan = mapPlanChoice(text);
    if (!plan) return client.sendMessage(msg.from, "Elegí: 1/2/3/4");
    s.plan = plan;
    s.step = "choose_app";
    return client.sendMessage(msg.from, appMenuText());
  }

  if (s.step === "choose_app") {
    const app = mapAppChoice(text);
    if (!app) return client.sendMessage(msg.from, "Elegí: 1/2/3");
    s.app = app;

    // If test: directly create without MP
    if (s.plan === "test") {
      if (app === "token") {
        const t = await createToken(phone, "test", 1);
        resetSession(phone);
        return client.sendMessage(msg.from,
          `✅ *Test ${TEST_HOURS}h* listo.\n🔑 Token: ${t.token}\n📅 Expira: ${t.expires_at || "∞"}\n\n📌 Escribí *menu* para ver opciones.`
        );
      } else {
        const u = await createDbUser(phone, "test", app);
        resetSession(phone);
        return client.sendMessage(msg.from,
          `✅ *Test ${TEST_HOURS}h* listo.\n👤 Usuario: ${u.username}\n🔐 Pass: ${u.password}\n📅 Expira: ${u.expires_at || "∞"}` + (app === "hc" ? ("\n\n🆔 Enviá tu *HWID* para activar.\n\n" + customDownloadText()) : (app === "apk" ? (downloadsCfg().apk_url ? ("\n\n📲 Descarga APK: " + downloadsCfg().apk_url) : "\n\n📲 Escribí *5* para descargar la app.") : ""))
        );
      }
    }

    // Paid plans:
    if (!MP_ENABLED) {
      resetSession(phone);
      return client.sendMessage(msg.from,
        `⚠️ MercadoPago no está configurado.\nContactá al admin para habilitar pagos.\n\n${pricesText()}`
      );
    }

    const pref = await mpCreatePreference({ phone, plan: s.plan, appType: app });
    resetSession(phone);
    return client.sendMessage(msg.from,
      `🧾 *Orden creada*\n• Plan: ${planLabel(s.plan)}\n• Tipo: ${appLabel(app)}\n• Total: $${planPrice(s.plan)} ${CURRENCY}\n\n✅ Pagá aquí:\n${pref.init_point}\n\n🔎 Luego enviá:\n*verificar ${pref.external_reference}*`
    );
  }

  // Default response minimal
  if (lower === "hola" || lower === "buenas" || lower === "buenos dias" || lower === "buenas tardes" || lower === "buenas noches") {
    return client.sendMessage(msg.from, `Hola 👋\n${helpText(isAdmin)}`);
  }
}

function saveQr(qr) {
  try { fs.writeFileSync(QR_TXT, qr, "utf8"); } catch {}
  try {
    qrcode.toFile(QR_PNG, qr, { width: 1024, margin: 2, errorCorrectionLevel: "H" }).catch(() => {});
  } catch {}
}

function main() {
  log(`${BOT_NAME} v${BOT_VERSION} iniciando...`);
  if (configPath) log(`Config: ${configPath}`);
  log(`DB: ${DB_FILE}`);
  log(`MercadoPago: ${MP_ENABLED ? "ON" : "OFF"}`);

  const client = new Client({
    authStrategy: new LocalAuth({ clientId: "ssh-bot", dataPath: BOT_HOME }),
    puppeteer: {
      headless: true,
      args: [
        "--no-sandbox",
        "--disable-setuid-sandbox",
        "--disable-dev-shm-usage",
        "--disable-accelerated-2d-canvas",
        "--no-first-run",
        "--no-zygote",
        "--single-process",
        "--disable-gpu"
      ]
    }
  });

  client.on("qr", (qr) => {
    log("QR generado. Guardando...");
    saveQr(qr);
    try { qrcodeTerminal.generate(qr, { small: true }); } catch {}
  });

  client.on("ready", () => {
    log("✅ WhatsApp listo.");
    try { fs.unlinkSync(QR_TXT); } catch {}
    try { fs.unlinkSync(QR_PNG); } catch {}
  });

  client.on("authenticated", () => log("🔐 Autenticado."));
  client.on("auth_failure", (msg) => log(`❌ Auth failure: ${msg}`));
  client.on("disconnected", (reason) => log(`⚠️ Desconectado: ${reason}`));

  client.on("message", async (msg) => {
    try {
      // ignore groups
      if (msg.from && msg.from.endsWith("@g.us")) return;
      await handleMessage(client, msg);
    } catch (e) {
      log(`ERR: ${e && e.stack ? e.stack : e}`);
      try { await client.sendMessage(msg.from, "⚠️ Error interno. Intentá de nuevo en unos segundos."); } catch {}
    }
  });


  // Enforce max_connections (best effort) – checks sshd sessions per user
  function countSshd(username) {
    try {
      const out = execSync(`pgrep -u ${username} -cx sshd 2>/dev/null || echo 0`, { stdio: ["ignore","pipe","ignore"] }).toString().trim();
      const n = parseInt(out, 10);
      return Number.isFinite(n) ? n : 0;
    } catch { return 0; }
  }

  async function enforceConnections() {
    try {
      const rows = await dbAll("SELECT username, max_connections FROM users WHERE status=1", []);
      for (const r of rows || []) {
        const u = r.username;
        if (!u) continue;
        const maxc = parseInt(r.max_connections || 1, 10) || 1;
        const online = countSshd(u);
        if (online > maxc) {
          log(`⚠️ ${u} conexiones ${online} > ${maxc} (cortando sshd)`);
          try { execSync(`pkill -u ${u} -x sshd 2>/dev/null || true`, { stdio: "ignore" }); } catch {}
        }
      }
    } catch {}
  }

  setInterval(enforceConnections, 30000);
  setTimeout(enforceConnections, 8000);
  client.initialize();
}

process.on("SIGINT", () => { try { db.close(); } catch {} process.exit(0); });
process.on("SIGTERM", () => { try { db.close(); } catch {} process.exit(0); });

main();
BOTJS
chmod +x "$BOT_HOME/bot.js" >/dev/null 2>&1 || true

echo -e "${CYAN}${BOLD}📦 Instalando dependencias Node...${NC}"
cat > "$BOT_HOME/package.json" <<'EOF'
{
  "name": "ssh-bot-pro",
  "version": "8.8.27",
  "description": "SSH Bot Pro WhatsApp",
  "main": "bot.js",
  "scripts": { "start": "node bot.js" },
  "dependencies": {
    "axios": "^1.6.5",
    "qrcode": "^1.5.4",
    "qrcode-terminal": "^0.12.0",
    "sqlite3": "^5.1.7",
    "whatsapp-web.js": "^1.24.0"
  }
}
EOF

cd "$BOT_HOME"
npm cache clean --force >/dev/null 2>&1 || true
npm install --silent >/dev/null 2>&1 || true

# Parche whatsapp-web.js (anti-markedUnread) – best-effort
# 1) Ajuste simple (cuando existe la clave markedUnread)
find node_modules/whatsapp-web.js -name "Client.js" -type f -exec \
  sed -i "s/markedUnread: true/markedUnread: false/g" {} \; 2>/dev/null || true
# 2) Fallback defensivo (algunas versiones traen el if(chat && chat.markedUnread))
find node_modules/whatsapp-web.js -name "Client.js" -type f -exec \
  sed -i "s/if (chat && chat.markedUnread)/if (false \\&\\& chat.markedUnread)/g" {} \; 2>/dev/null || true
# 3) Fallback extra (deshabilitar sendSeen si tu build lo usa y rompe por markedUnread)
find node_modules/whatsapp-web.js -name "Client.js" -type f -exec \
  sed -i "s/const sendSeen = async (chatId) => {/const sendSeen = async (chatId) => { console.log(\\"[DEBUG] sendSeen deshabilitado\\"); return; /g" {} \; 2>/dev/null || true

# Auto-refresh cada 2 horas
( crontab -l 2>/dev/null | grep -v 'ssh-bot-refresh' ) | crontab - || true
echo "0 */2 * * * pm2 restart $BOT_NAME >/dev/null 2>&1 # ssh-bot-refresh" | crontab - || true

# Limpieza expirados cada 15 min (DB)
( crontab -l 2>/dev/null | grep -v 'ssh-bot-clean' ) | crontab - || true
echo "*/15 * * * * sqlite3 $DB_FILE \"DELETE FROM users WHERE expires_at IS NOT NULL AND datetime(expires_at) <= datetime('now');\" >/dev/null 2>&1 # ssh-bot-clean" | crontab - || true

echo -e "${CYAN}${BOLD}🚀 Iniciando bot con PM2...${NC}"
pm2 delete "$BOT_NAME" >/dev/null 2>&1 || true
pm2 start "$BOT_HOME/bot.js" --name "$BOT_NAME" --cwd "$BOT_HOME" >/dev/null 2>&1 || true
pm2 save >/dev/null 2>&1 || true

# ================================================
# PANEL ADMIN (COMANDO sshbot)
# ================================================
echo -e "${CYAN}${BOLD}📊 Instalando panel admin (sshbot)...${NC}"
PANEL_PATH="/usr/local/bin/ssh-bot-panel.sh"
mkdir -p /usr/local/bin

cat > "$PANEL_PATH" <<'PANELEOF'
#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/opt/ssh-bot"
BOT_HOME="/root/ssh-bot"
DB_FILE="$INSTALL_DIR/data/users.db"
CONFIG_FILE="$INSTALL_DIR/config/config.json"
BOT_NAME="ssh-bot"

QR_PNG="/root/qr-whatsapp.png"
QR_TXT="/root/qr-whatsapp.txt"

APK_DIR="$BOT_HOME/apks"
HC_DIR="$BOT_HOME/hc"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

need_cmd() { command -v "$1" >/dev/null 2>&1; }
pausa(){ read -rp "Presioná ENTER para continuar..." _ || true; }

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH:-}"

PM2_BIN=""
pm2_resolve(){ PM2_BIN="$(command -v pm2 2>/dev/null || true)"; }
pm2_run(){
  pm2_resolve
  if [[ -n "${PM2_BIN}" ]]; then
    "${PM2_BIN}" "$@"
    return $?
  fi
  echo -e "${RED}❌ pm2 no está instalado o no está en PATH.${NC}"
  echo -e "${YELLOW}➡️ Solución: ejecutá en la VPS:${NC}"
  echo -e "   npm i -g pm2  ${YELLOW}(o rerun del instalador)${NC}"
  return 127
}

ensure_runtime(){
  # Instala deps mínimas del panel si faltan (no rompe si ya existen)
  local pkgs=()
  for c in jq sqlite3 curl wget; do
    command -v "$c" >/dev/null 2>&1 || pkgs+=("$c")
  done

  if [[ ${#pkgs[@]} -gt 0 ]]; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y >/dev/null 2>&1 || true
    apt-get install -y "${pkgs[@]}" >/dev/null 2>&1 || true
  fi

  # Asegurar pm2
  if ! command -v pm2 >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y >/dev/null 2>&1 || true

    if ! command -v npm >/dev/null 2>&1; then
      # Node 20 + npm
      curl -fsSL https://deb.nodesource.com/setup_20.x | bash - >/dev/null 2>&1 || true
      apt-get install -y nodejs >/dev/null 2>&1 || true
    fi

    npm i -g pm2 >/dev/null 2>&1 || true
    hash -r 2>/dev/null || true
  fi

  pm2_resolve
}
require_root() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    echo -e "${RED}❌ Ejecutar como root${NC}"
    exit 1
  fi
}

ensure_dirs() {
  mkdir -p "$INSTALL_DIR"/{data,config,qr_codes,logs,backups} "$BOT_HOME"/{config,data,apks,hc,logs} >/dev/null 2>&1 || true
  chmod 700 "$INSTALL_DIR/config" >/dev/null 2>&1 || true
}

get_json() { jq -r "$1" "$CONFIG_FILE" 2>/dev/null || echo ""; }

set_json() {
  local filter="$1"
  local tmp
  tmp="$(mktemp)"
  jq "$filter" "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
  chmod 600 "$CONFIG_FILE" || true
  cp -f "$CONFIG_FILE" "$BOT_HOME/config/config.json" >/dev/null 2>&1 || true
  # Upgrade/migrate config (add missing keys without overwriting existing values)
  set_json '(
    .bot.name //= "SSH BOT ELNENE PRO" |
    .bot.version //= "8.8.27" |
    .prices.test_hours //= 2 |
    .prices.plan_7 //= 500 |
    .prices.plan_15 //= 800 |
    .prices.plan_30 //= 1200 |
    .prices.currency //= "ARS" |
    .mercadopago //= {"access_token":"","enabled":false} |
    .gemini //= {"enabled":false,"api_key":""} |
    .links //= {"tutorial":"https://youtube.com","support":"https://t.me/soporte","support_whatsapp":"","telegram":""} |
    .links.tutorial //= "https://youtube.com" |
    .links.support //= "https://t.me/soporte" |
    .links.support_whatsapp //= "" |
    .links.telegram //= "" |
    .downloads //= {"apk_url":"","custom_url":"","custom_message":"📲 *HTTP Custom*\\n\\n⬇️ Descargá desde:\\n{URL}\\n\\nLuego importá tu archivo .hc (HWID) y conectá."} |
    .downloads.apk_url //= "" |
    .downloads.custom_url //= "" |
    .downloads.custom_message //= "📲 *HTTP Custom*\\n\\n⬇️ Descargá desde:\\n{URL}\\n\\nLuego importá tu archivo .hc (HWID) y conectá."
  )'
}

ensure_config() {
  ensure_dirs
  if [[ ! -s "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" <<'JSON'
{
  "bot": { "name": "SSH BOT ELNENE PRO", "version": "8.8.27" },
  "admins": [],
  "prices": { "test_hours": 2, "plan_7": 500, "plan_15": 800, "plan_30": 1200, "currency": "ARS" },
  "mercadopago": { "access_token": "", "enabled": false },
  "gemini": { "enabled": false, "api_key": "" },
  "links": {
    "tutorial": "https://youtube.com",
    "support": "https://t.me/soporte",
    "support_whatsapp": "",
    "telegram": ""
  },
  "downloads": {
    "apk_url": "",
    "custom_url": "",
    "custom_message": "📲 *HTTP Custom*\n\n⬇️ Descargá desde:\n{URL}\n\nLuego importá tu archivo .hc (HWID) y conectá."
  }
}
JSON
    chmod 600 "$CONFIG_FILE" || true
  fi
  mkdir -p "$BOT_HOME/config" >/dev/null 2>&1 || true
  cp -f "$CONFIG_FILE" "$BOT_HOME/config/config.json" >/dev/null 2>&1 || true
}

ensure_db() {
  ensure_dirs
  sqlite3 "$DB_FILE" "CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      phone TEXT,
      username TEXT UNIQUE,
      password TEXT,
      tipo TEXT,
      expires_at DATETIME,
      max_connections INTEGER DEFAULT 1,
      status INTEGER DEFAULT 1,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      app_type TEXT DEFAULT '',
      hwid TEXT DEFAULT ''
    );" >/dev/null 2>&1 || true

  sqlite3 "$DB_FILE" "CREATE TABLE IF NOT EXISTS tokens (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      phone TEXT,
      token TEXT UNIQUE,
      plan TEXT,
      expires_at TEXT,
      status TEXT DEFAULT 'active',
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );" >/dev/null 2>&1 || true

  sqlite3 "$DB_FILE" "CREATE TABLE IF NOT EXISTS payments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      phone TEXT,
      external_reference TEXT UNIQUE,
      preference_id TEXT,
      amount REAL,
      currency TEXT,
      status TEXT DEFAULT 'pending',
      plan TEXT,
      app_type TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      approved_at TEXT
    );" >/dev/null 2>&1 || true
}

pm2_status() {
  pm2_resolve
  if [[ -z "${PM2_BIN}" ]]; then echo "OFF"; return; fi
  local st
  st="$(pm2_run jlist 2>/dev/null | jq -r '.[]|select(.name=="'"$BOT_NAME"'")|.pm2_env.status' | head -n1)"
  [[ -z "$st" || "$st" == "null" ]] && st="OFF"
  echo "$st"
}

count_users_total() {
  [[ -f "$DB_FILE" ]] || { echo 0; return; }
  sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM users;" 2>/dev/null || echo 0
}

count_users_active() {
  [[ -f "$DB_FILE" ]] || { echo 0; return; }
  sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM users WHERE expires_at IS NULL OR datetime(expires_at) > datetime('now');" 2>/dev/null || echo 0
}

count_premium_active() {
  sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM users WHERE tipo='premium' AND (expires_at IS NULL OR datetime(expires_at) > datetime('now'));" 2>/dev/null || echo 0
}

estado_sistema() {
  local st total active mp apk prem
  st="$(pm2_status)"
  total="$(count_users_total)"
  active="$(count_users_active)"
  prem="$(count_premium_active)"
  mp="$(get_json '.mercadopago.access_token // empty')"
  [[ -n "$mp" && "$mp" != "null" ]] && mp="✅ ACTIVO" || mp="❌ NO CONFIG"
  [[ -n "$(ls -1 "$APK_DIR"/*.apk 2>/dev/null | head -n1)" ]] && apk="✅ DISPONIBLE" || apk="❌ NO"
  echo -e "${CYAN}📊 ESTADO DEL SISTEMA${NC}"
  echo "┌─────────────────────────────────────┐"
  echo "│ Bot WhatsApp: $st"
  echo "│ Usuarios: $active/$total activos/total"
  echo "│ Premium: $prem usuarios"
  echo "│ MercadoPago: $mp"
  echo "│ APK: $apk"
  echo "│ QR: $([[ -s "$QR_TXT" || -s "$QR_PNG" ]] && echo 'LISTO' || echo 'NO')"
  echo "└─────────────────────────────────────┘"
  echo
}

# ---------- BOT CONTROL ----------
bot_control_menu() {
  while true; do
    clear
    estado_sistema
    echo -e "${BOLD}🚀 Control bot (PM2)${NC}"
    echo "[1] Iniciar/Reiniciar"
    echo "[2] Detener"
    echo "[3] Ver logs"
    echo "[0] Volver"
    read -rp "Opción: " o
    case "$o" in
      1) if pm2_run describe "$BOT_NAME" >/dev/null 2>&1; then pm2_run restart "$BOT_NAME" >/dev/null 2>&1 || true; else pm2_run start "$BOT_HOME/bot.js" --name "$BOT_NAME" --cwd "$BOT_HOME" >/dev/null 2>&1 || true; fi; pm2_run save >/dev/null 2>&1 || true; echo "OK"; pausa ;;
      2) pm2_run stop "$BOT_NAME" >/dev/null 2>&1 || true; pm2_run save >/dev/null 2>&1 || true; echo "OK"; pausa ;;
      3) pm2_run logs "$BOT_NAME" --lines 220; pausa ;;
      0) return ;;
      *) echo "Inválido"; sleep 1 ;;
    esac
  done
}

# ---------- QR ----------
reset_whatsapp_session() {
  rm -rf "$BOT_HOME/.wwebjs_auth" "$BOT_HOME/.wwebjs_cache" "/root/.wwebjs_auth" "/root/.wwebjs_cache" >/dev/null 2>&1 || true
  rm -f "$QR_PNG" "$QR_TXT" >/dev/null 2>&1 || true
}

show_qr_console() {
  echo -e "${BOLD}🧾 QR en consola${NC}"
  echo
  if [[ -s "$QR_TXT" ]] && need_cmd qrencode; then
    qrencode -t ANSIUTF8 < "$QR_TXT" || true
    echo
    return 0
  fi
  pm2_run logs "$BOT_NAME" --lines 260 --nostream 2>/dev/null | tail -n 260 || true
}

show_qr_png() {
  if [[ -s "$QR_PNG" ]]; then
    echo -e "${GREEN}✅ PNG guardado: $QR_PNG${NC}"
    if need_cmd chafa; then
      chafa -s 70x40 "$QR_PNG" 2>/dev/null || true
    elif need_cmd viu; then
      viu -w 60 "$QR_PNG" 2>/dev/null || true
    else
      echo -e "${YELLOW}No hay visor en terminal. Abrilo manualmente: ls -lah $QR_PNG${NC}"
    fi
  fi
}

ver_qr() {
  while true; do
    clear
    echo -e "${CYAN}${BOLD}📱 WhatsApp – QR / Vinculación${NC}"
    echo "----------------------------------------"
    echo "[1] Ver QR actual (sin borrar sesión)"
    echo "[2] Forzar QR nuevo (borrar sesión + reiniciar)"
    echo "[3] Ver logs (PM2)"
    echo "[0] Volver"
    echo
    read -rp "Opción: " q
    case "$q" in
      1)
        echo
        echo -e "${CYAN}🧾 Mostrando QR (si está disponible)...${NC}"
        echo
        show_qr_console || true
        echo
        show_qr_png || true
        pausa
        ;;
      2)
        clear
        echo -e "${CYAN}${BOLD}📱 Forzar QR NUEVO${NC}"
        echo "----------------------------------------"
        echo -e "${YELLOW}⚠️  Esto borra sesión y fuerza un QR NUEVO.${NC}"
        echo
        reset_whatsapp_session
        echo -e "${CYAN}🔁 Reiniciando bot...${NC}"
        if pm2_run describe "$BOT_NAME" >/dev/null 2>&1; then
          pm2_run restart "$BOT_NAME" >/dev/null 2>&1 || true
        else
          pm2_run start "$BOT_HOME/bot.js" --name "$BOT_NAME" --cwd "$BOT_HOME" >/dev/null 2>&1 || true
        fi
        pm2_run save >/dev/null 2>&1 || true

        echo -e "${CYAN}⏳ Esperando QR (hasta 45s)...${NC}"
        for i in {1..45}; do
          [[ -s "$QR_TXT" || -s "$QR_PNG" ]] && break
          sleep 1
        done
        echo
        show_qr_console || true
        echo
        show_qr_png || true
        echo
        echo -e "${CYAN}👉 Escanealo desde tu WhatsApp principal: Dispositivos vinculados.${NC}"
        pausa
        ;;
      3)
        pm2_run logs "$BOT_NAME" --lines 220
        pausa
        ;;
      0) return ;;
      *) echo "Opción inválida"; sleep 1 ;;
    esac
  done
}

# ---------- MERCADOPAGO ----------
mp_configurar_token() {
  ensure_config
  local curr
  curr="$(get_json '.mercadopago.access_token // empty')"
  clear
  echo -e "${CYAN}${BOLD}💳 MercadoPago – Token${NC}"
  echo "----------------------------------------"
  if [[ -n "$curr" && "$curr" != "null" ]]; then
    echo "Actual: ${curr:0:12}********"
  else
    echo "Actual: (vacío)"
  fi
  echo
  echo -e "${YELLOW}Formato válido:${NC} debe empezar con ${BOLD}APP_USR-${NC} (producción) o ${BOLD}TEST-${NC} (test)."
  echo
  read -rp "Pegá el nuevo token (enter=cancelar): " tok
  [[ -z "$tok" ]] && { echo "Cancelado."; pausa; return; }

  if [[ ! "$tok" =~ ^APP_USR- ]] && [[ ! "$tok" =~ ^TEST- ]]; then
    echo -e "${RED}❌ Token inválido.${NC}"
    echo -e "${YELLOW}Debe empezar con APP_USR- o TEST-${NC}"
    pausa
    return
  fi

  set_json ".mercadopago.access_token = \"$tok\" | .mercadopago.enabled = true"
  echo -e "${GREEN}✅ Token guardado.${NC}"
  echo -e "${YELLOW}🔄 Reiniciando bot para aplicar...${NC}"
  pm2_run restart "$BOT_NAME" >/dev/null 2>&1 || true
  pm2_run save >/dev/null 2>&1 || true
  pausa
}


# ---------- PRECIOS ----------
cambiar_precios() {
  ensure_config
  local p7 p15 p30
  p7="$(get_json '.prices.plan_7 // 0')"
  p15="$(get_json '.prices.plan_15 // 0')"
  p30="$(get_json '.prices.plan_30 // 0')"
  clear
  echo -e "${CYAN}${BOLD}💲 Precios${NC}"
  echo "7 días : $p7"
  echo "15 días: $p15"
  echo "30 días: $p30"
  echo
  read -rp "Nuevo 7 días (enter=mantener): " np7
  read -rp "Nuevo 15 días (enter=mantener): " np15
  read -rp "Nuevo 30 días (enter=mantener): " np30
  [[ -z "$np7" ]] && np7="$p7"
  [[ -z "$np15" ]] && np15="$p15"
  [[ -z "$np30" ]] && np30="$p30"
  set_json ".prices.plan_7 = ($np7|tonumber) | .prices.plan_15 = ($np15|tonumber) | .prices.plan_30 = ($np30|tonumber)"
  echo -e "${GREEN}✅ Precios actualizados.${NC}"
  pausa
}

# ---------- APK ----------
apk_menu() {
  ensure_dirs
  while true; do
    clear
    echo -e "${CYAN}${BOLD}📲 Gestión APK${NC}"
    echo "[1] Listar APK"
    echo "[2] Subir APK (descargar por URL)"
    echo "[4] Importar APK desde /root (copiar)"
    echo "[3] Borrar APK"
    echo "[0] Volver"
    read -rp "Opción: " o
    case "$o" in
      1)
        ls -lah "$APK_DIR"/*.apk 2>/dev/null || echo "No hay APKs."
        pausa
        ;;
      2)
        read -rp "URL directa del .apk: " url
        [[ -z "$url" ]] && { echo "Cancelado."; pausa; continue; }
        fn="$(basename "$url")"
        [[ "$fn" != *.apk ]] && fn="app_$(date +%s).apk"
        wget -qO "$APK_DIR/$fn" "$url" || curl -fsSL "$url" -o "$APK_DIR/$fn" || true
        if [[ -s "$APK_DIR/$fn" ]]; then
          echo -e "${GREEN}✅ Guardado: $APK_DIR/$fn${NC}"
        else
          rm -f "$APK_DIR/$fn" >/dev/null 2>&1 || true
          echo -e "${RED}❌ No pude descargar.${NC}"
        fi
        pausa
        ;;
      3)
        ls -1 "$APK_DIR"/*.apk 2>/dev/null || { echo "No hay APKs."; pausa; continue; }
        echo
        read -rp "Nombre exacto a borrar (ej: algo.apk): " name
        [[ -z "$name" ]] && { echo "Cancelado."; pausa; continue; }
        rm -f "$APK_DIR/$name" >/dev/null 2>&1 || true
        echo "OK"
        pausa
        ;;
      4)
        # Importar APK desde /root (copiar a $APK_DIR)
        mapfile -t found < <(find /root -maxdepth 2 -type f -name "*.apk" 2>/dev/null | sort -r)
        if [[ "${#found[@]}" -eq 0 ]]; then
          echo "No encontré .apk en /root."
          echo "Tip: subí tu APK a /root/app.apk"
          pausa
          continue
        fi
        echo
        echo "APKs encontrados en /root:"
        local idx=1
        for f in "${found[@]}"; do
          local sz; sz="$(du -h "$f" 2>/dev/null | awk '{print $1}')"
          echo "  [$idx] $f  ($sz)"
          idx=$((idx+1))
        done
        echo
        read -rp "Elegí número para copiar a $APK_DIR (0=cancelar): " sel
        [[ -z "$sel" || "$sel" == "0" ]] && { echo "Cancelado."; pausa; continue; }
        if ! [[ "$sel" =~ ^[0-9]+$ ]] || (( sel < 1 || sel > ${#found[@]} )); then
          echo "Inválido."
          pausa
          continue
        fi
        src_apk="${found[$((sel-1))]}"
        base="$(basename "$src_apk")"
        cp -f "$src_apk" "$APK_DIR/$base" >/dev/null 2>&1 || true
        if [[ -s "$APK_DIR/$base" ]]; then
          chmod 644 "$APK_DIR/$base" >/dev/null 2>&1 || true
          echo -e "${GREEN}✅ Importado: $APK_DIR/$base${NC}"
        else
          rm -f "$APK_DIR/$base" >/dev/null 2>&1 || true
          echo -e "${RED}❌ No pude copiar.${NC}"
        fi
        pausa
        ;;
      0) return ;;
      *) echo "Inválido"; sleep 1 ;;
    esac
  done
}

# ---------- HC / HWID ----------
hc_menu() {
  ensure_dirs
  while true; do
    clear
    echo -e "${CYAN}${BOLD}🧩 Gestión .hc (HWID)${NC}"
    echo "[1] Listar .hc"
    echo "[2] Crear .hc manual (por HWID)"
    echo "[3] Borrar .hc"
    echo "[0] Volver"
    read -rp "Opción: " o
    case "$o" in
      1)
        ls -lah "$HC_DIR"/*.hc 2>/dev/null || echo "No hay .hc."
        pausa
        ;;
      2)
        read -rp "HWID: " hw
        [[ -z "$hw" ]] && { echo "Cancelado."; pausa; continue; }
        fp="$HC_DIR/$hw.hc"
        echo "HWID=$hw" > "$fp"
        echo -e "${GREEN}✅ Creado: $fp${NC}"
        pausa
        ;;
      3)
        ls -1 "$HC_DIR"/*.hc 2>/dev/null || { echo "No hay .hc."; pausa; continue; }
        read -rp "Nombre exacto a borrar (ej: ABC.hc): " name
        [[ -z "$name" ]] && { echo "Cancelado."; pausa; continue; }
        rm -f "$HC_DIR/$name" >/dev/null 2>&1 || true
        echo "OK"
        pausa
        ;;
      0) return ;;
      *) echo "Inválido"; sleep 1 ;;
    esac
  done
}

# ---------- USUARIOS ----------
usuarios_menu() {
  ensure_db

  auto_user(){ echo "user$(tr -dc 'a-z0-9' </dev/urandom | head -c 6)"; }
  auto_pass(){ tr -dc 'A-Za-z0-9' </dev/urandom | head -c 12; }

  user_online_sessions() {
    local u="$1"
    # Count sshd processes running as user (best effort)
    local c
    c="$(pgrep -u "$u" -c sshd 2>/dev/null || echo 0)"
    [[ -z "$c" ]] && c=0
    echo "$c"
  }

  list_users() {
    echo -e "${CYAN}${BOLD}👥 Usuarios (con online)${NC}"
    echo
    mapfile -t rows < <(sqlite3 -separator '|' "$DB_FILE" "SELECT username,tipo,expires_at,max_connections,status FROM users ORDER BY id DESC LIMIT 80;")
    if [[ "${#rows[@]}" -eq 0 ]]; then
      echo "(sin usuarios)"
      return
    fi

    printf "%-18s %-8s %-19s %-6s %-7s %-8s\n" "USERNAME" "TIPO" "EXPIRES" "MAX" "STATUS" "ONLINE"
    printf "%-18s %-8s %-19s %-6s %-7s %-8s\n" "------------------" "--------" "-------------------" "------" "-------" "--------"
    for r in "${rows[@]}"; do
      IFS='|' read -r u tipo exp mc st <<< "$r"
      [[ -z "$u" ]] && continue
      local on="0"
      if id -u "$u" >/dev/null 2>&1; then
        on="$(user_online_sessions "$u")"
      fi
      [[ -z "$mc" ]] && mc="1"
      [[ -z "$st" ]] && st="1"
      printf "%-18s %-8s %-19s %-6s %-7s %-8s\n" "$u" "${tipo:-?}" "${exp:-NULL}" "$mc" "$st" "$on"
    done
  }

  create_user_manual() {
    clear
    echo -e "${CYAN}${BOLD}👤 Crear usuario manual${NC}"
    echo "----------------------------------------"
    read -rp "Teléfono (opcional): " phone
    read -rp "Usuario (vacío=auto): " u
    read -rp "Contraseña (vacío=auto): " p
    read -rp "Días (0=test 2h): " days
    read -rp "Conexiones max (1): " mc
    read -rp "Tipo (test/premium) (auto): " tipo

    [[ -z "$u" ]] && u="$(auto_user)"
    [[ -z "$p" ]] && p="$(auto_pass)"
    [[ -z "$days" ]] && days="30"
    [[ -z "$mc" ]] && mc="1"

    if [[ "$days" == "0" ]]; then
      tipo="test"
      exp_full="$(date -d "+2 hours" "+%Y-%m-%d %H:%M:%S")"
      exp_date="$(date -d "+2 hours" "+%Y-%m-%d")"
    else
      [[ -z "$tipo" ]] && tipo="premium"
      exp_full="$(date -d "+${days} days 23:59:59" "+%Y-%m-%d %H:%M:%S")"
      exp_date="$(date -d "+${days} days" "+%Y-%m-%d")"
    fi

    # DB
    if sqlite3 "$DB_FILE" "SELECT 1 FROM users WHERE username='$u' LIMIT 1;" 2>/dev/null | grep -q 1; then
      echo -e "${RED}❌ Ya existe en DB: $u${NC}"
      pausa; return
    fi

    # Linux user
    if id -u "$u" >/dev/null 2>&1; then
      echo -e "${YELLOW}⚠️ Ya existe en Linux: $u (no recreo)${NC}"
      echo "$u:$p" | chpasswd >/dev/null 2>&1 || true
    else
      useradd -m -s /bin/bash "$u" >/dev/null 2>&1 || { echo -e "${RED}❌ Error useradd${NC}"; pausa; return; }
      echo "$u:$p" | chpasswd >/dev/null 2>&1 || true
    fi
    chage -E "$exp_date" "$u" >/dev/null 2>&1 || true

    sqlite3 "$DB_FILE" "INSERT INTO users(phone,username,password,tipo,expires_at,max_connections,status) VALUES('${phone}','${u}','${p}','${tipo}','${exp_full}',${mc},1);" >/dev/null 2>&1 || {
      echo -e "${RED}❌ Error insert DB${NC}"
      pausa; return
    }

    echo
    echo -e "${GREEN}✅ Usuario creado${NC}"
    echo "👤 $u"
    echo "🔑 $p"
    echo "⏰ Expira: $exp_full"
    echo "🔌 Max conexiones: $mc"
    pausa
  }

  renovar_usuario() {
    clear
    echo -e "${CYAN}${BOLD}📅 Renovar / Cambiar fecha${NC}"
    echo "----------------------------------------"
    read -rp "Username: " u
    [[ -z "$u" ]] && { echo "Cancelado."; pausa; return; }

    local cur
    cur="$(sqlite3 "$DB_FILE" "SELECT expires_at FROM users WHERE username='$u' LIMIT 1;" 2>/dev/null || true)"
    if [[ -z "$cur" || "$cur" == "null" ]]; then
      cur="$(date "+%Y-%m-%d %H:%M:%S")"
    fi

    echo "Actual expires_at: ${cur}"
    echo
    read -rp "Días a sumar (0=test 2h desde ahora): " days
    [[ -z "$days" ]] && { echo "Cancelado."; pausa; return; }

    if [[ "$days" == "0" ]]; then
      new_full="$(date -d "+2 hours" "+%Y-%m-%d %H:%M:%S")"
      new_date="$(date -d "+2 hours" "+%Y-%m-%d")"
      sqlite3 "$DB_FILE" "UPDATE users SET tipo='test', expires_at='${new_full}', status=1 WHERE username='${u}';" >/dev/null 2>&1 || true
    else
      # base: si estaba vencido, renovamos desde ahora
      base_ts="$(date -d "$cur" +%s 2>/dev/null || date +%s)"
      now_ts="$(date +%s)"
      [[ "$base_ts" -lt "$now_ts" ]] && base_ts="$now_ts"
      base_fmt="$(date -d "@$base_ts" "+%Y-%m-%d %H:%M:%S")"
      new_full="$(date -d "$base_fmt +${days} days" "+%Y-%m-%d 23:59:59")"
      new_date="$(date -d "$base_fmt +${days} days" "+%Y-%m-%d")"
      sqlite3 "$DB_FILE" "UPDATE users SET tipo='premium', expires_at='${new_full}', status=1 WHERE username='${u}';" >/dev/null 2>&1 || true
    fi

    if id -u "$u" >/dev/null 2>&1; then
      chage -E "$new_date" "$u" >/dev/null 2>&1 || true
    fi

    echo -e "${GREEN}✅ Actualizado${NC} -> $new_full"
    pausa
  }

  cambiar_clave() {
    clear
    echo -e "${CYAN}${BOLD}🔑 Cambiar contraseña${NC}"
    echo "----------------------------------------"
    read -rp "Username: " u
    [[ -z "$u" ]] && { echo "Cancelado."; pausa; return; }
    read -rp "Nueva contraseña (vacío=auto): " p
    [[ -z "$p" ]] && p="$(auto_pass)"

    if id -u "$u" >/dev/null 2>&1; then
      echo "$u:$p" | chpasswd >/dev/null 2>&1 || true
    fi
    sqlite3 "$DB_FILE" "UPDATE users SET password='${p}' WHERE username='${u}';" >/dev/null 2>&1 || true

    echo -e "${GREEN}✅ Clave actualizada${NC}"
    echo "👤 $u"
    echo "🔑 $p"
    pausa
  }

  cambiar_conexiones() {
    clear
    echo -e "${CYAN}${BOLD}🔌 Cambiar max conexiones${NC}"
    echo "----------------------------------------"
    read -rp "Username: " u
    [[ -z "$u" ]] && { echo "Cancelado."; pausa; return; }
    read -rp "Nuevo max (1): " mc
    [[ -z "$mc" ]] && mc="1"

    sqlite3 "$DB_FILE" "UPDATE users SET max_connections=${mc} WHERE username='${u}';" >/dev/null 2>&1 || true

    # Si está pasado, cortar sshd
    if id -u "$u" >/dev/null 2>&1; then
      on="$(user_online_sessions "$u")"
      if [[ "$on" -gt "$mc" ]]; then
        pkill -u "$u" -x sshd >/dev/null 2>&1 || true
      fi
    fi

    echo -e "${GREEN}✅ Max conexiones actualizado${NC} -> $mc"
    pausa
  }

  eliminar_usuario() {
    clear
    echo -e "${CYAN}${BOLD}🗑️ Eliminar usuario${NC}"
    echo "----------------------------------------"
    read -rp "Username a borrar: " u
    [[ -z "$u" ]] && { echo "Cancelado."; pausa; return; }
    sqlite3 "$DB_FILE" "DELETE FROM users WHERE username='${u}';" >/dev/null 2>&1 || true
    if id -u "$u" >/dev/null 2>&1; then
      pkill -u "$u" >/dev/null 2>&1 || true
      userdel -r "$u" >/dev/null 2>&1 || true
    fi
    echo -e "${GREEN}✅ Borrado: $u${NC}"
    pausa
  }

  eliminar_expirados() {
    mapfile -t exp < <(sqlite3 "$DB_FILE" "SELECT username FROM users WHERE expires_at IS NOT NULL AND datetime(expires_at) <= datetime('now');" 2>/dev/null || true)
    if [[ "${#exp[@]}" -eq 0 ]]; then
      echo "No hay expirados."
      pausa; return
    fi
    echo "Expirados:"
    printf ' - %s\n' "${exp[@]}"
    echo
    read -rp "¿Eliminar TODOS? (s/N): " yn
    [[ ! "$yn" =~ ^[Ss]$ ]] && { echo "Cancelado."; pausa; return; }
    for u in "${exp[@]}"; do
      sqlite3 "$DB_FILE" "DELETE FROM users WHERE username='${u}';" >/dev/null 2>&1 || true
      if id -u "$u" >/dev/null 2>&1; then
        pkill -u "$u" >/dev/null 2>&1 || true
        userdel -r "$u" >/dev/null 2>&1 || true
      fi
    done
    echo -e "${GREEN}✅ Expirados eliminados: ${#exp[@]}${NC}"
    pausa
  }

  conectados_ahora() {
    clear
    echo -e "${CYAN}${BOLD}🔌 Conectados ahora (best-effort)${NC}"
    echo "----------------------------------------"
    echo -e "${YELLOW}who:${NC}"
    who || true
    echo
    echo -e "${YELLOW}sshd (procesos):${NC}"
    ps -eo user,comm,args | grep -E "sshd: " | grep -v grep || echo "(sin sshd visibles)"
    echo
    pausa
  }

  while true; do
    clear
    echo -e "${CYAN}${BOLD}👥 Usuarios (DB + Linux)${NC}"
    echo "[1] Listar (con online)"
    echo "[2] Crear usuario manual"
    echo "[3] Renovar / Cambiar fecha"
    echo "[4] Cambiar contraseña"
    echo "[5] Cambiar conexiones"
    echo "[6] Eliminar usuario (DB + Linux)"
    echo "[7] Eliminar expirados (DB + Linux)"
    echo "[8] Conectados ahora"
    echo "[0] Volver"
    echo
    read -rp "Opción: " o
    case "$o" in
      1) clear; list_users; pausa ;;
      2) create_user_manual ;;
      3) renovar_usuario ;;
      4) cambiar_clave ;;
      5) cambiar_conexiones ;;
      6) eliminar_usuario ;;
      7) eliminar_expirados ;;
      8) conectados_ahora ;;
      0) return ;;
      *) echo "Inválido"; sleep 1 ;;
    esac
  done
}

tokens_menu() {
  ensure_db
  while true; do
    clear
    echo -e "${CYAN}${BOLD}🔑 Tokens (Token-Only)${NC}"
    echo "[1] Listar (últimos 60)"
    echo "[2] Generar token"
    echo "[3] Revocar token"
    echo "[0] Volver"
    read -rp "Opción: " o
    case "$o" in
      1)
        sqlite3 -header -column "$DB_FILE" "SELECT token,plan,expires_at,status,created_at FROM tokens ORDER BY id DESC LIMIT 60;"
        pausa
        ;;
      2)
        read -rp "Phone (solo números, opcional): " ph
        read -rp "Plan (7/15/30/test): " pl
        [[ -z "$pl" ]] && { echo "Cancelado."; pausa; continue; }
        tok="TKN_$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 22)"
        exp=""
        case "$pl" in
          7) exp="$(date -u -d '+7 days' '+%F %T')" ;;
          15) exp="$(date -u -d '+15 days' '+%F %T')" ;;
          30) exp="$(date -u -d '+30 days' '+%F %T')" ;;
          test) exp="$(date -u -d '+1 days' '+%F %T')" ;;
          *) exp="" ;;
        esac
        sqlite3 "$DB_FILE" "INSERT INTO tokens(phone,token,plan,expires_at,status) VALUES('$ph','$tok','$pl','$exp','active');" >/dev/null 2>&1 || true
        echo -e "${GREEN}✅ Token: $tok${NC}"
        echo "Expira: ${exp:-∞}"
        pausa
        ;;
      3)
        read -rp "Token a revocar: " t
        [[ -z "$t" ]] && { echo "Cancelado."; pausa; continue; }
        sqlite3 "$DB_FILE" "UPDATE tokens SET status='revoked' WHERE token='$t';" >/dev/null 2>&1 || true
        echo "OK"
        pausa
        ;;
      0) return ;;
      *) echo "Inválido"; sleep 1 ;;
    esac
  done
}

# ---------- ESTADÍSTICAS ----------
stats_menu() {
  ensure_db
  clear
  echo -e "${CYAN}${BOLD}📊 Estadísticas / Ventas / Ganancias${NC}"
  local total approved sum
  total="$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM payments;" 2>/dev/null || echo 0)"
  approved="$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM payments WHERE status='approved';" 2>/dev/null || echo 0)"
  sum="$(sqlite3 "$DB_FILE" "SELECT IFNULL(SUM(amount),0) FROM payments WHERE status='approved';" 2>/dev/null || echo 0)"
  echo "• Pagos totales: $total"
  echo "• Aprobados: $approved"
  echo "• Ganancia aprobada: $sum"
  echo
  echo -e "${BOLD}Últimos 20 pagos:${NC}"
  sqlite3 -header -column "$DB_FILE" "SELECT phone,amount,currency,status,plan,app_type,created_at FROM payments ORDER BY id DESC LIMIT 20;" 2>/dev/null || true
  pausa
}

# ---------- MIGRAR ----------
migrar_usuario_a_token() {
  ensure_db
  clear
  echo -e "${CYAN}${BOLD}🔁 Migrar usuario -> Token${NC}"
  read -rp "Username: " u
  [[ -z "$u" ]] && { echo "Cancelado."; pausa; return; }
  local row
  row="$(sqlite3 -separator '|' "$DB_FILE" "SELECT phone,expires_at,tipo FROM users WHERE username='$u' LIMIT 1;")"
  if [[ -z "$row" ]]; then
    echo "No existe."
    pausa
    return
  fi
  local ph exp tipo
  ph="$(cut -d'|' -f1 <<<"$row")"
  exp="$(cut -d'|' -f2 <<<"$row")"
  tipo="$(cut -d'|' -f3 <<<"$row")"

  tok="TKN_$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 22)"
  sqlite3 "$DB_FILE" "INSERT INTO tokens(phone,token,plan,expires_at,status) VALUES('$ph','$tok','$tipo','$exp','active');" >/dev/null 2>&1 || true
  sqlite3 "$DB_FILE" "DELETE FROM users WHERE username='$u';" >/dev/null 2>&1 || true
  id -u "$u" >/dev/null 2>&1 && userdel -r "$u" >/dev/null 2>&1 || true

  echo -e "${GREEN}✅ Migrado.${NC}"
  echo "Token: $tok"
  echo "Expira: ${exp:-∞}"
  pausa
}

# ---------- UPDATE ----------
update_menu() {
  clear
  echo -e "${CYAN}${BOLD}🔄 Update (anti-cuelgue)${NC}"
  echo "Esto ejecuta: npm install + restart PM2 (si hay git también hace pull)."
  echo
  if [[ -d "$BOT_HOME/.git" ]]; then
    echo -e "${CYAN}➡️ git pull...${NC}"
    (cd "$BOT_HOME" && git pull) || true
  fi
  echo -e "${CYAN}➡️ npm install...${NC}"
  (cd "$BOT_HOME" && npm install --silent) || true
  echo -e "${CYAN}➡️ restart PM2...${NC}"
  if pm2_run describe "$BOT_NAME" >/dev/null 2>&1; then
    pm2_run restart "$BOT_NAME" >/dev/null 2>&1 || true
  else
    pm2_run start "$BOT_HOME/bot.js" --name "$BOT_NAME" --cwd "$BOT_HOME" >/dev/null 2>&1 || true
  fi
  pm2_run save >/dev/null 2>&1 || true
  echo -e "${GREEN}✅ Update OK.${NC}"
  pausa
}


# ---------- AJUSTES (Soporte / IA / Descargas) ----------
ajustes_menu() {
  ensure_config
  while true; do
    clear
    echo -e "${CYAN}${BOLD}⚙️ Ajustes${NC}"
    echo "[1] 📞 Soporte (WhatsApp / Telegram / Link)"
    echo "[2] 🧠 IA Gemini (API Key)"
    echo "[3] 🌐 Descargas (APK URL / HTTP Custom)"
    echo "[0] Volver"
    echo
    read -rp "Opción: " o
    case "$o" in
      1) ajustar_soporte ;;
      2) ajustar_gemini ;;
      3) ajustar_descargas ;;
      0) return ;;
      *) echo -e "${RED}❌ Opción inválida${NC}"; sleep 1 ;;
    esac
  done
}

ajustar_soporte() {
  ensure_config
  local sup wa tg tut
  sup="$(get_json '.links.support // ""')"
  wa="$(get_json '.links.support_whatsapp // ""')"
  tg="$(get_json '.links.telegram // ""')"
  tut="$(get_json '.links.tutorial // ""')"

  clear
  echo -e "${CYAN}${BOLD}📞 Configurar soporte y links${NC}"
  echo "----------------------------------------"
  echo "• Soporte (link):        ${sup}"
  echo "• WhatsApp (wa.me):      ${wa}"
  echo "• Telegram (t.me/alias): ${tg}"
  echo "• Tutorial:              ${tut}"
  echo
  read -rp "Nuevo link soporte (enter=mantener): " nsup
  read -rp "Nuevo link WhatsApp wa.me (enter=mantener): " nwa
  read -rp "Nuevo alias/link Telegram (enter=mantener): " ntg
  read -rp "Nuevo link tutorial (enter=mantener): " ntut

  [[ -z "$nsup" ]] && nsup="$sup"
  [[ -z "$nwa" ]] && nwa="$wa"
  [[ -z "$ntg" ]] && ntg="$tg"
  [[ -z "$ntut" ]] && ntut="$tut"

  set_json ".links.support = \"$nsup\" | .links.support_whatsapp = \"$nwa\" | .links.telegram = \"$ntg\" | .links.tutorial = \"$ntut\""
  echo -e "${GREEN}✅ Guardado.${NC}"
  echo -e "${YELLOW}Tip: reiniciá el bot (PM2) para aplicar al instante si no actualiza solo.${NC}"
  pausa
}

ajustar_gemini() {
  ensure_config
  local en key
  en="$(get_json '.gemini.enabled // false')"
  key="$(get_json '.gemini.api_key // ""')"

  clear
  echo -e "${CYAN}${BOLD}🧠 IA Gemini${NC}"
  echo "----------------------------------------"
  echo "Estado: $en"
  if [[ -n "$key" && "$key" != "null" ]]; then
    echo "Key: ${key:0:8}********"
  else
    echo "Key: (vacía)"
  fi
  echo
  read -rp "¿Habilitar IA? (s/N): " yn
  if [[ "$yn" == "s" || "$yn" == "S" ]]; then
    set_json ".gemini.enabled = true"
  elif [[ "$yn" == "n" || "$yn" == "N" || -z "$yn" ]]; then
    # no cambia
    :
  fi

  read -rp "Pegar API Key (enter=mantener): " nk
  [[ -n "$nk" ]] && set_json ".gemini.api_key = \"$nk\""

  echo -e "${GREEN}✅ Configurado.${NC}"
  echo -e "${YELLOW}Recomendado: reiniciar bot para aplicar (PM2 -> restart).${NC}"
  pausa
}

ajustar_descargas() {
  ensure_config
  local apkurl curl cmsg
  apkurl="$(get_json '.downloads.apk_url // ""')"
  curl="$(get_json '.downloads.custom_url // ""')"
  cmsg="$(get_json '.downloads.custom_message // ""')"

  clear
  echo -e "${CYAN}${BOLD}🌐 Descargas (cliente)${NC}"
  echo "----------------------------------------"
  echo "APK URL (si no se envía archivo):"
  echo "  $apkurl"
  echo
  echo "HTTP Custom URL:"
  echo "  $curl"
  echo
  echo "Mensaje HTTP Custom (usa {URL} como placeholder):"
  echo "  $(echo "$cmsg" | head -n 3)"
  echo
  read -rp "Nuevo APK URL (enter=mantener): " napk
  read -rp "Nuevo HTTP Custom URL (enter=mantener): " ncurl
  echo
  echo "Editar mensaje HTTP Custom ahora? (s/N)"
  read -rp "> " edit
  if [[ "$edit" == "s" || "$edit" == "S" ]]; then
    echo "Pegá el mensaje completo. Terminá con una línea que diga: EOF"
    tmp="$(mktemp)"
    while IFS= read -r line; do
      [[ "$line" == "EOF" ]] && break
      echo "$line" >> "$tmp"
    done
    newmsg="$(cat "$tmp")"
    rm -f "$tmp"
    [[ -n "$newmsg" ]] && cmsg="$newmsg"
  fi

  [[ -z "$napk" ]] && napk="$apkurl"
  [[ -z "$ncurl" ]] && ncurl="$curl"

  set_json ".downloads.apk_url = \"$napk\" | .downloads.custom_url = \"$ncurl\" | .downloads.custom_message = \"$cmsg\""
  echo -e "${GREEN}✅ Guardado.${NC}"
  pausa
}

main_menu() {
  require_root
  ensure_dirs
  ensure_config
  ensure_db
  ensure_runtime

  while true; do
    clear
    estado_sistema
    echo "[1] 🚀 Control bot (PM2)"
    echo "[2] 📱 Ver QR WhatsApp"
    echo "[3] 💳 MercadoPago: configurar token"
    echo "[4] 💲 Cambiar precios (7/15/30)"
    echo "[5] 📲 Gestión APK"
    echo "[6] 🧩 Gestión .hc (HWID)"
    echo "[7] 👥 Usuarios (DB + expirados + conectados)"
    echo "[8] 🔑 Tokens (Token-Only)"
    echo "[9] 📊 Estadísticas / Ventas / Ganancias"
    echo "[10] 🔁 Migrar usuario -> Token"
    echo "[11] 🔄 Update (npm install + restart)"
    echo "[12] ⚙️ Ajustes (Soporte / IA / Descargas)"
    echo "[0] 🚪 Salir"
    echo
    read -rp "Opción: " opt
    case "$opt" in
      1) bot_control_menu ;;
      2) ver_qr ;;
      3) mp_configurar_token ;;
      4) cambiar_precios ;;
      5) apk_menu ;;
      6) hc_menu ;;
      7) usuarios_menu ;;
      8) tokens_menu ;;
      9) stats_menu ;;
      10) migrar_usuario_a_token ;;
      11) update_menu ;;
      12) ajustes_menu ;;
      0) exit 0 ;;
      *) echo -e "${RED}❌ Opción inválida${NC}"; sleep 1 ;;
    esac
  done
}

main_menu
PANELEOF

chmod +x "$PANEL_PATH"
ln -sf "$PANEL_PATH" /usr/local/bin/sshbot
chmod +x /usr/local/bin/sshbot
hash -r 2>/dev/null || true

echo
echo -e "${GREEN}${BOLD}✅ Instalación EMBED completada.${NC}"
echo -e "${CYAN}👉 Panel: ${BOLD}sshbot${NC}"
echo -e "${CYAN}👉 QR: en panel opción [2] (borra sesión + fuerza QR nuevo)${NC}"
echo
