-- ==============================================================================
-- MedDuty Supabase PostgreSQL Database Schema
-- Run this in Supabase Dashboard > SQL Editor > New Query
-- ==============================================================================

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. USERS TABLE
create table if not exists public.users (
  uid text primary key,
  name text default '',
  email text default '',
  role text default '',
  "profilePhoto" text default '',
  "coverPhoto" text default '',
  phone text default '',
  bio text default '',
  qualification text default '',
  experience integer default 0,
  specialization text default '',
  "hospitalAffiliation" text default '',
  certificates jsonb default '[]'::jsonb,
  rating numeric default 0.0,
  reviews jsonb default '[]'::jsonb,
  location jsonb,
  availability boolean default true,
  "availableForDuties" boolean default true,
  "emergencyAvailable" boolean default false,
  "walletBalance" numeric default 0.0,
  "accountStatus" text default 'active',
  "profileVisible" boolean default true,
  "isDiscoverable" boolean default true,
  "onlineStatus" text default 'offline',
  "currentHospital" text default '',
  "currentCity" text default '',
  state text default '',
  country text default '',
  "authProvider" text default 'email',
  "createdAt" timestamptz default now(),
  "updatedAt" timestamptz default now(),
  "joinedDate" timestamptz default now(),
  "deactivatedAt" timestamptz
);

-- 2. DUTIES TABLE
create table if not exists public.duties (
  id text primary key default uuid_generate_v4()::text,
  "hospitalId" text default '',
  "hospitalName" text default '',
  role text default '',
  salary numeric default 0.0,
  location text default '',
  "dutyDate" timestamptz not null,
  "startTime" timestamptz not null,
  "endTime" timestamptz not null,
  status text default 'upcoming',
  "createdAt" timestamptz default now(),
  "updatedAt" timestamptz,
  notes text,
  "applicantIds" jsonb default '[]'::jsonb,
  "selectedApplicantId" text,
  latitude double precision,
  longitude double precision,
  geohash text,
  "isEmergency" boolean default false,
  "urgencyLevel" text,
  "incentiveAmount" numeric,
  "emergencyExpiresAt" timestamptz
);

-- 3. DUTY APPLICATIONS
create table if not exists public.duty_applications (
  id text primary key default uuid_generate_v4()::text,
  "userId" text not null,
  "dutyId" text not null,
  "hospitalId" text default '',
  "hospitalName" text default '',
  role text default '',
  location text default '',
  "dutyDate" timestamptz not null,
  status text default 'pending',
  "appliedAt" timestamptz default now(),
  "updatedAt" timestamptz,
  notes text,
  salary numeric
);

-- 4. HOSPITALS TABLE
create table if not exists public.hospitals (
  id text primary key,
  name text not null,
  type text default 'Multi-speciality Hospital',
  location text default '',
  city text default '',
  speciality text,
  rating numeric default 0.0,
  "imageUrl" text default '',
  "createdAt" timestamptz default now()
);

-- 5. CHATS TABLE
create table if not exists public.chats (
  id text primary key default uuid_generate_v4()::text,
  participants jsonb default '[]'::jsonb,
  "lastMessage" text default '',
  "lastMessageTime" timestamptz default now(),
  "createdAt" timestamptz default now()
);

-- 6. MESSAGES TABLE
create table if not exists public.messages (
  id text primary key default uuid_generate_v4()::text,
  "chatId" text not null,
  "senderId" text not null,
  content text default '',
  "mediaUrl" text,
  "mediaType" text,
  "createdAt" timestamptz default now(),
  "isRead" boolean default false
);

-- 7. COMMUNITY POSTS
create table if not exists public.community_posts (
  id text primary key default uuid_generate_v4()::text,
  "authorId" text not null,
  "authorName" text default '',
  "authorAvatar" text,
  content text not null,
  "imageUrls" jsonb default '[]'::jsonb,
  "documentUrls" jsonb default '[]'::jsonb,
  "likedBy" jsonb default '[]'::jsonb,
  "commentsCount" integer default 0,
  "repostCount" integer default 0,
  "createdAt" timestamptz default now(),
  "isProfessional" boolean default true,
  category text,
  visibility text default 'public',
  "authorSpecialty" text,
  "authorHospital" text,
  "authorRole" text,
  "authorVerified" boolean default false,
  "experienceMeta" jsonb default '{}'::jsonb,
  hidden boolean default false,
  "hiddenReason" text
);

-- 8. POST COMMENTS
create table if not exists public.post_comments (
  id text primary key default uuid_generate_v4()::text,
  "postId" text not null,
  "authorId" text not null,
  "authorName" text default '',
  content text not null,
  "createdAt" timestamptz default now(),
  "likedBy" jsonb default '[]'::jsonb
);

-- 9. NOTIFICATIONS
create table if not exists public.notifications (
  id text primary key default uuid_generate_v4()::text,
  "userId" text not null,
  type text default 'general',
  title text not null,
  body text default '',
  "postId" text,
  "authorId" text,
  read boolean default false,
  "createdAt" timestamptz default now()
);

-- 10. JOBS TABLE
create table if not exists public.jobs (
  id text primary key default uuid_generate_v4()::text,
  "hospitalId" text default '',
  "hospitalName" text default '',
  title text not null,
  specialization text default '',
  "employmentType" text default '',
  location text default '',
  "salaryMin" numeric default 0,
  "salaryMax" numeric default 0,
  description text default '',
  requirements jsonb default '[]'::jsonb,
  skills jsonb default '[]'::jsonb,
  verified boolean default false,
  status text default 'open',
  "workMode" text default 'on-site',
  "postedAt" timestamptz default now(),
  "applicationDeadline" timestamptz,
  latitude double precision,
  longitude double precision,
  geohash text
);

-- 11. JOB APPLICATIONS
create table if not exists public.job_applications (
  id text primary key default uuid_generate_v4()::text,
  "userId" text not null,
  "jobId" text not null,
  "hospitalId" text default '',
  "hospitalName" text default '',
  title text default '',
  location text default '',
  status text default 'applied',
  "appliedAt" timestamptz default now(),
  "updatedAt" timestamptz,
  "resumeUrl" text,
  "salaryMin" numeric,
  "salaryMax" numeric,
  "applicationType" text default 'job'
);

-- 12. REVIEWS TABLE
create table if not exists public.reviews (
  id text primary key default uuid_generate_v4()::text,
  "userId" text not null,
  "authorId" text not null,
  "authorName" text default '',
  rating numeric default 5.0,
  comment text default '',
  "createdAt" timestamptz default now()
);

-- 13. WALLET TRANSACTIONS
create table if not exists public.wallet_transactions (
  id text primary key default uuid_generate_v4()::text,
  "userId" text not null,
  type text not null,
  amount numeric not null,
  "balanceAfter" numeric not null,
  description text default '',
  "createdAt" timestamptz default now(),
  "dutyId" text,
  "withdrawalMethod" text,
  "withdrawalStatus" text
);

-- 14. SAVED ITEMS
create table if not exists public.saved_items (
  id text primary key default uuid_generate_v4()::text,
  "userId" text not null,
  type text not null,
  "itemId" text not null,
  title text default '',
  subtitle text,
  "imageUrl" text,
  salary numeric,
  "savedAt" timestamptz default now()
);

-- 15. ACTIVITY ITEMS
create table if not exists public.activity_items (
  id text primary key default uuid_generate_v4()::text,
  "userId" text not null,
  type text default 'notification',
  title text not null,
  description text,
  "relatedId" text,
  "createdAt" timestamptz default now()
);

-- 16. DOCUMENTS
create table if not exists public.documents (
  id text primary key default uuid_generate_v4()::text,
  "userId" text not null,
  name text default '',
  url text default '',
  type text default '',
  "uploadedAt" timestamptz default now()
);

-- 17. RESUMES
create table if not exists public.resumes (
  id text primary key default uuid_generate_v4()::text,
  "userId" text not null,
  name text default '',
  url text default '',
  "uploadedAt" timestamptz default now()
);

-- 18. FOLLOWERS & FOLLOWING
create table if not exists public.followers (
  id text primary key default uuid_generate_v4()::text,
  "userId" text not null,
  "targetId" text not null,
  name text,
  specialization text,
  "createdAt" timestamptz default now()
);

create table if not exists public.following (
  id text primary key default uuid_generate_v4()::text,
  "userId" text not null,
  "targetId" text not null,
  name text,
  specialization text,
  "createdAt" timestamptz default now()
);

-- Enable Realtime on core tables
alter publication supabase_realtime add table public.users;
alter publication supabase_realtime add table public.duties;
alter publication supabase_realtime add table public.duty_applications;
alter publication supabase_realtime add table public.community_posts;
alter publication supabase_realtime add table public.post_comments;
alter publication supabase_realtime add table public.notifications;
alter publication supabase_realtime add table public.jobs;
alter publication supabase_realtime add table public.job_applications;
alter publication supabase_realtime add table public.saved_items;
alter publication supabase_realtime add table public.activity_items;
alter publication supabase_realtime add table public.wallet_transactions;
