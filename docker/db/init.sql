CREATE TABLE IF NOT EXISTS public.login (
  username varchar(64) PRIMARY KEY,
  password varchar(128) NOT NULL
);
