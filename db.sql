create schema til;

drop table if exists til.comment cascade;
drop table if exists til.vote cascade;
drop table if exists til.til cascade;
drop table if exists til.user cascade;

;
create table til.user (
  id serial primary key,
  slack_id text not null,
  name text not null,
  email text,
  image_url text,
  created_at timestamp with time zone not null default now(),
  unique (slack_id)
)

;
create table til.til (
  id serial primary key,
  text text not null,
  user_id integer references til.user,
  created_at timestamp with time zone not null default now()
)

;
create table til.vote (
  id serial primary key,
  til_id integer references til.til,
  user_id integer references til.user,
  value integer not null default 1,
  created_at timestamp with time zone not null default now(),
  modified_at timestamp with time zone,
  unique (til_id, user_id),
  constraint vote_value check (value >= -1 and value <= 1)
)


;
create table til.comment (
  id serial primary key,
  text text not null,
  til_id integer references til.til,
  user_id integer references til.user,
  created_at timestamp with time zone not null default now()
)
