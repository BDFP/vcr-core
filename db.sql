create table IF NOT EXISTS auth_data (
       access_token TEXT NOT NULL,
       expires_in INTEGER NOT NULL,
       refresh_token TEXT NOT NULL,
       scope TEXT NOT NULL,
       token_type TEXT NOT NULL
)
