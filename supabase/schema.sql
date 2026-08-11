-- 志工服務報名系統 — Supabase 資料表
-- 用法：在 Supabase 專案左側「SQL Editor」貼上全部並按 Run

-- 1) 後台設定（名單、課室、活動、地點庫）：以單一 JSON 存放，由管理員維護
create table if not exists app_config (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz default now()
);

-- 2) 報名紀錄：每筆一列，避免多人同時報名互相覆蓋
create table if not exists signups (
  id text primary key,
  person_id text not null,
  occ_id text not null,
  slot text default '',
  attended boolean default false,
  ts bigint,
  created_at timestamptz default now()
);
create index if not exists signups_occ_idx on signups(occ_id);
create index if not exists signups_person_idx on signups(person_id);

-- 3) 開啟 Row Level Security，允許匿名(anon)讀寫
--    ⚠️ 此工具不需登入，任何拿到網址與 anon key 的人都能讀寫資料。
alter table app_config enable row level security;
alter table signups   enable row level security;

drop policy if exists "anon all on app_config" on app_config;
drop policy if exists "anon all on signups"    on signups;
create policy "anon all on app_config" on app_config for all to anon using (true) with check (true);
create policy "anon all on signups"    on signups    for all to anon using (true) with check (true);

-- 4) 開啟 signups 即時同步（多人即時看到彼此報名）
alter publication supabase_realtime add table signups;
