# Development Scripts

Cross-cutting scripts for managing the Thala monorepo.

## 🚀 Stack Management

### `start-all.sh`
Start the entire development stack (Docker services: PostgreSQL, MeiliSearch, MinIO, Backend).

```bash
./scripts/start-all.sh
```

### `stop-all.sh`
Stop all Docker services.

```bash
./scripts/stop-all.sh
```

## 🧹 Maintenance

### `clean-all.sh`
Clean all build artifacts across the monorepo (Flutter, Next.js, Python cache).

```bash
./scripts/clean-all.sh
```

### `reset-db.sh`
Reset the database and run migrations (⚠️ destructive - deletes all data).

```bash
./scripts/reset-db.sh
```

## 📱 Component-Specific Scripts

Component-specific scripts live with their components for easier maintenance:

### Mobile (`mobile/`)
- **`run_local.sh`** - Run Flutter app with local backend

```bash
cd mobile
./run_local.sh -- -d macos
```

## 💡 Usage Tips

**Make scripts executable:**
```bash
chmod +x scripts/*.sh
```

**Run from any directory:**
```bash
# These scripts use absolute paths, so you can run them from anywhere
./scripts/start-all.sh
```

**Chain commands:**
```bash
# Clean, start stack, and run mobile app
./scripts/clean-all.sh && ./scripts/start-all.sh && cd mobile && ./run_local.sh
```

## 🔧 Adding New Scripts

When adding scripts:
- ✅ **Cross-cutting scripts** → Put in `/scripts/` (affect multiple components)
- ✅ **Component scripts** → Keep with component (e.g., `mobile/`, `backend/`)
- ✅ **Document here** → Add to this README with description and usage
- ✅ **Make executable** → `chmod +x script.sh`
- ✅ **Use set -e** → Fail fast on errors
- ✅ **Add help text** → Echo what the script does
