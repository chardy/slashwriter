-- +------------------------------------------+
-- |                 PROFILES                 |
-- +------------------------------------------+
create table if not exists profiles (
  id uuid references auth.users not null,
  username citext unique not null,
  email citext unique not null,
  avatar_url text,

  primary key (id),
  unique(username),
  constraint username_length check (char_length(username) >= 3)
);


-- +------------------------------------------+
-- |                  FOLDERS                 |
-- +------------------------------------------+
create table if not exists folders (
  id uuid default uuid_generate_v4() not null,
  user_id uuid references auth.users not null,
  name citext not null,
  color citext default '#8F95B2' not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,

  primary key (id),
  constraint name_length check (char_length(name) >= 3),
  constraint color_hex_format check (color ~ '^#[a-zA-Z0-9]{6}$')
);


-- +------------------------------------------+
-- |                  SHARES                  |
-- +------------------------------------------+
create table if not exists shares (
  id uuid default uuid_generate_v4() not null,
  user_id uuid references auth.users not null,
  document_id uuid not null unique,
  include_subdocuments boolean default true not null,
  anyone_can_read boolean default false not null,
  anyone_can_edit boolean default false not null,
  users_can_read uuid[] references auth.users,
  users_can_edit uuid[] references auth.users,

  primary key (id)
);


-- +------------------------------------------+
-- |                 DOCUMENTS                |
-- +------------------------------------------+
create table if not exists documents (
  id uuid default uuid_generate_v4() not null,
  user_id uuid references auth.users not null,
  folder uuid references folders not null,
  path citext default '/'not null,
  title citext not null,
  previous_titles citext[],
  text citext default '' not null,
  state bytea,
  share_settings uuid references shares,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  archived_at timestamp with time zone,
  deleted_at timestamp with time zone,

  primary key (id),
  constraint title_length check (char_length(title) >= 3),
  constraint path_of_uuid check (path ~ '^\/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\/)*$')
);

alter table shares
  add foreign key (document_id) references documents (id)
  deferrable initially deferred;