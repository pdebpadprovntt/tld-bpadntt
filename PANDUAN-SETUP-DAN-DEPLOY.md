# Panduan Clone & Deploy Website BPAD NTT dari GitHub

> **Panduan ini untuk**: Setup dari nol di laptop lain + deploy ke hosting VPS Hostinger dengan aaPanel.

---

## Bagian A: Setup Development di Laptop Lain (Clone dari GitHub)

### Prasyarat di Laptop Baru

Pastikan sudah terinstall:

| Software | Versi | Cara Cek |
|----------|-------|----------|
| PHP | 8.3+ | `php -v` |
| Composer | 2.x | `composer -V` |
| Node.js | 20+ | `node -v` |
| npm | 10+ | `npm -v` |
| Git | 2.x | `git --version` |
| SQLite | 3.x | `sqlite3 --version` |

> **Jika belum terinstall**: Lihat [Lampiran A — Install Prasyarat di macOS](#lampiran-a--install-prasyarat-di-macos)

---

### Langkah 1: Clone Repository dari GitHub

Buka **Terminal** dan jalankan:

```bash
cd ~/Documents
git clone git@github.com:pdebpadprovntt/tld-bpadntt.git tld-bpadntt-dev
cd tld-bpadntt-dev
```

> Jika menggunakan HTTPS (password/token):  
> `git clone https://github.com/pdebpadprovntt/tld-bpadntt.git tld-bpadntt-dev`

---

### Langkah 2: Setup Environment (.env)

```bash
cp .env.example .env
```

Buka `.env` dengan editor, lalu **ubah bagian database** menjadi SQLite untuk development:

```ini
DB_CONNECTION=sqlite
# Hapus atau comment baris DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD
```

> SQLite digunakan di dev agar tidak perlu install MySQL/PostgreSQL.

---

### Langkah 3: Install Dependencies & Build

```bash
composer install
npm install
npm run build
```

---

### Langkah 4: Generate Key & Setup Database

```bash
php artisan key:generate
touch database/database.sqlite
php artisan migrate --force
```

---

### Langkah 5: Buat Akun Admin

```bash
php artisan bpad:admin \
  --username=admin \
  --email=admin@bpadntt.local \
  --name="Administrator BPAD" \
  --password="PasswordAnda123"
```

> **Ganti `PasswordAnda123`** dengan password yang kuat!

---

### Langkah 6: Jalankan Server

```bash
php artisan serve --host=127.0.0.1 --port=8000
```

Akses:
- Website: **http://127.0.0.1:8000**
- Admin: **http://127.0.0.1:8000/admin/login**

---

## Bagian B: Sync Data Antar Laptop (Git Workflow)

### Di Laptop Lama (sebelum pindah ke laptop baru)

```bash
cd "D:\VELLA\SISTEM\TLD-BPAD"

# Pastikan semua perubahan sudah di-commit
git add .
git commit -m "Pesan perubahan"
git push origin main
```

### Di Laptop Baru (setelah clone)

```bash
cd ~/Documents/tld-bpadntt-dev

# Ambil perubahan terbaru
git pull origin main
```

### Catatan Penting Git

- File **`.env`** tidak ikut di-push (ada di `.gitignore`). Setup ulang di tiap laptop.
- File **`database/database.sqlite`** tidak ikut di-push. Database dev tiap laptop terpisah.
- Folder **`storage/`** dan file upload tidak ikut di-push. Upload via admin panel di dev lokal masing-masing.

---

## Bagian C: Deploy ke Hosting Produksi (VPS Hostinger + aaPanel)

### Arsitektur Hosting

```
┌──────────────────────────────────────────┐
│  VPS Hostinger (212.85.26.65)           │
│  ┌────────────────────────────────────┐  │
│  │  aaPanel                           │  │
│  │  ├── Nginx (web server)            │  │
│  │  ├── PHP 8.3 (FPM)                 │  │
│  │  ├── MySQL (database produksi)     │  │
│  │  └── phpMyAdmin (opsional)         │  │
│  └────────────────────────────────────┘  │
└──────────────────────────────────────────┘
```

---

### Prasyarat di VPS (via aaPanel)

Pastikan sudah terinstall melalui aaPanel:

1. **Nginx** — sebagai web server
2. **PHP 8.3** — dengan ekstensi: `pdo_mysql`, `mbstring`, `xml`, `gd`, `zip`, `curl`, `openssl`, `tokenizer`
3. **MySQL 8.x** atau **MariaDB 10.x**
4. **Git** — untuk clone repository
5. **Composer 2.x** — untuk install dependency PHP

---

### Langkah 1: Clone Repository ke VPS

SSH ke VPS:

```bash
ssh root@212.85.26.65
```

Clone repo ke folder web:

```bash
cd /www/wwwroot
git clone git@github.com:pdebpadprovntt/tld-bpadntt.git tld-bpadntt
cd tld-bpadntt
```

---

### Langkah 2: Setup .env untuk Produksi

```bash
cp .env.example .env
```

Edit `.env` dengan nano/vim:

```bash
nano .env
```

Isi dengan konfigurasi produksi:

```ini
APP_NAME="Website BPAD NTT"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://bpad.nttprov.go.id

APP_TIMEZONE=Asia/Makassar
APP_LOCALE=id
APP_FALLBACK_LOCALE=id
APP_FAKER_LOCALE=id_ID

APP_MAINTENANCE_DRIVER=file

BCRYPT_ROUNDS=12

LOG_CHANNEL=stack
LOG_STACK=single
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=warning

# ===== DATABASE PRODUKSI (MYSQL) =====
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=bpadntt
DB_USERNAME=bpadntt_user
DB_PASSWORD=ISI_PASSWORD_MYSQL_ANDA

SESSION_DRIVER=database
SESSION_LIFETIME=120
SESSION_ENCRYPT=false
SESSION_PATH=/
SESSION_DOMAIN=null
SESSION_SECURE_COOKIE=true
SESSION_HTTP_ONLY=true
SESSION_SAME_SITE=lax

BROADCAST_CONNECTION=log
FILESYSTEM_DISK=local
QUEUE_CONNECTION=database

CACHE_STORE=database

MAIL_MAILER=log
MAIL_FROM_ADDRESS="pdebpadntt@gmail.com"
MAIL_FROM_NAME="${APP_NAME}"

VITE_APP_NAME="${APP_NAME}"

BPAD_ADMIN_NAME="Administrator BPAD"
BPAD_ADMIN_USERNAME=admin
BPAD_ADMIN_EMAIL=pdebpadntt@gmail.com
```

---

### Langkah 3: Buat Database MySQL di aaPanel

1. Buka aaPanel di browser: `https://212.85.26.65:7800`
2. Menu **Database** → **Add Database**
3. Isi:
   - Database Name: `bpadntt`
   - Username: `bpadntt_user`
   - Password: _(gunakan password yang sama dengan di `.env`)_

---

### Langkah 4: Install Dependencies & Build

```bash
composer install --optimize-autoloader --no-dev
php artisan key:generate
php artisan storage:link
php artisan migrate --force
npm install --ignore-scripts
npm run build
```

---

### Langkah 5: Buat Akun Admin

```bash
php artisan bpad:admin \
  --username=admin \
  --email=pdebpadntt@gmail.com \
  --name="Administrator BPAD" \
  --password="PASSWORD_AMAN_ANDA"
```

---

### Langkah 6: Cache untuk Produksi

```bash
php artisan optimize
```

---

### Langkah 7: Set Permission Folder

```bash
chown -R www:www /www/wwwroot/tld-bpadntt
chmod -R 755 /www/wwwroot/tld-bpadntt
chmod -R 775 /www/wwwroot/tld-bpadntt/storage
chmod -R 775 /www/wwwroot/tld-bpadntt/bootstrap/cache
```

---

### Langkah 8: Konfigurasi Nginx di aaPanel

1. Buka aaPanel → **Website** → Add Site
2. Isi:
   - Domain: `bpad.nttprov.go.id` (atau domain Anda)
   - Root: `/www/wwwroot/tld-bpadntt/public`
   - PHP Version: PHP 8.3
3. Klik **Submit**

4. Edit konfigurasi Nginx, tambahkan rewrite rule untuk Laravel:

```nginx
location / {
    try_files $uri $uri/ /index.php?$query_string;
}
```

5. Restart Nginx.

---

### Langkah 9: Setup SSL (HTTPS)

Di aaPanel → **Website** → Klik domain Anda → **SSL** → **Let's Encrypt** → Apply.

---

### Langkah 10: Verifikasi Deploy

Buka browser, akses domain Anda:
- Website: `https://bpad.nttprov.go.id`
- Admin: `https://bpad.nttprov.go.id/admin/login`

---

## Bagian D: Workflow Update Produksi (dari Laptop Manapun)

Setiap kali ada perubahan kode, deploy ke produksi:

```bash
# 1. Di laptop development — commit & push
cd ~/Documents/tld-bpadntt-dev
git add .
git commit -m "Deskripsi perubahan"
git push origin main

# 2. SSH ke VPS — pull & update
ssh root@212.85.26.65
cd /www/wwwroot/tld-bpadntt
git pull origin main
composer install --optimize-autoloader --no-dev
php artisan migrate --force
php artisan optimize
php artisan view:clear
```

---

## Lampiran A — Install Prasyarat di macOS

### 1. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install PHP 8.3 + Composer

```bash
brew install php@8.3 composer
```

### 3. Install Node.js & npm

```bash
brew install node
```

### 4. Install Git

```bash
brew install git
```

### 5. Setup SSH Key untuk GitHub (Wajib!)

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "email@anda.com"

# Copy isi public key
cat ~/.ssh/id_ed25519.pub
```

Buka **GitHub → Settings → SSH and GPG keys → New SSH Key**. Paste isi public key tadi.

### 6. Konfigurasi Git

```bash
git config --global user.name "Nama Anda"
git config --global user.email "email@anda.com"
```

---

## Lampiran B — Troubleshooting

| Masalah | Solusi |
|---------|--------|
| `could not find driver (SQLite)` | Install ekstensi: `brew install sqlite` lalu `php -m \| grep sqlite` |
| `could not find driver (MySQL)` di dev | Cek `.env`, pastikan `DB_CONNECTION=sqlite` |
| `storage/logs/laravel.log` permission | `chmod -R 775 storage bootstrap/cache` |
| `The stream or file could not be opened` | Jalankan `php artisan storage:link` |
| Class not found setelah deploy | `composer dump-autoload` lalu `php artisan optimize:clear` |
| Nginx 500 Error | Cek log: `tail -f /www/wwwlogs/error.log` |
| Git push ditolak | Pastikan SSH key sudah ditambah ke GitHub |
| `VITE_*` environment variable missing | Jalankan `npm run build` |

---

## Lampiran C — Checklist Ringkas

### Setup Laptop Baru
- [ ] Install PHP 8.3, Composer, Node.js, Git, SQLite
- [ ] Setup SSH key + tambahkan ke GitHub
- [ ] `git clone git@github.com:pdebpadprovntt/tld-bpadntt.git`
- [ ] `cp .env.example .env` + edit DB ke sqlite
- [ ] `composer install && npm install && npm run build`
- [ ] `php artisan key:generate`
- [ ] `touch database/database.sqlite && php artisan migrate --force`
- [ ] `php artisan bpad:admin` (buat user admin)
- [ ] `php artisan serve`

### Deploy Produksi
- [ ] Clone repo ke VPS (`/www/wwwroot/tld-bpadntt`)
- [ ] Setup `.env` produksi (MySQL)
- [ ] Buat database dan user di aaPanel
- [ ] `composer install --optimize-autoloader --no-dev`
- [ ] `php artisan key:generate && php artisan storage:link`
- [ ] `php artisan migrate --force`
- [ ] `npm install --ignore-scripts && npm run build`
- [ ] `php artisan bpad:admin` (buat user admin)
- [ ] `php artisan optimize`
- [ ] Set permission folder (`chown`, `chmod`)
- [ ] Konfigurasi Nginx site + root ke `/public`
- [ ] Pasang SSL Let's Encrypt
- [ ] Verifikasi website & admin login

---

> **Repo GitHub**: `git@github.com:pdebpadprovntt/tld-bpadntt.git`  
> **VPS Hostinger**: `212.85.26.65` (aaPanel)  
> **Dibuat**: 7 Januari 2026