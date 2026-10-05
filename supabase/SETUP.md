# Supabase Project Setup & Credentials

## Active Project Credentials
- **Project Ref**: `vrhbezoxiuymwwwyhqbp`
- **Project URL**: `https://vrhbezoxiuymwwwyhqbp.supabase.co`
- **Publishable / Anon Key**: `sb_publishable_Eo6h5QqIDeYo3-K0GAZPZQ_Ezx5Rm4e`
- **Direct Database Connection**:
  ```text
  postgresql://postgres:[YOUR-PASSWORD]@db.vrhbezoxiuymwwwyhqbp.supabase.co:5432/postgres
  ```

---

## Supabase CLI Setup Instructions

If you haven't installed the Supabase CLI yet on Windows, install it via Scoop or npm:
```powershell
# Via Scoop (recommended for Windows):
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase

# Or via npm (if Node.js is installed):
npm install -g supabase
```

### CLI Commands:
1. **Login to your Supabase account:**
   ```powershell
   supabase login
   ```
2. **Initialize Supabase local config in this project:**
   ```powershell
   supabase init
   ```
3. **Link to your remote Supabase project:**
   ```powershell
   supabase link --project-ref vrhbezoxiuymwwwyhqbp
   ```
   *(Note: You will be prompted to enter your database password for `[YOUR-PASSWORD]`)*

4. **Push database schema / migrations (Optional):**
   ```powershell
   supabase db push
   ```
