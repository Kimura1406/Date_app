CREATE TABLE IF NOT EXISTS profiles (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    age INT NOT NULL,
    job TEXT NOT NULL,
    bio TEXT NOT NULL,
    distance TEXT NOT NULL,
    interests TEXT[] NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS matches (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    last_message TEXT NOT NULL,
    last_seen TEXT NOT NULL,
    status TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
