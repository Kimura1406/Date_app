ALTER TABLE users
ADD COLUMN IF NOT EXISTS birth_date DATE,
ADD COLUMN IF NOT EXISTS country TEXT NOT NULL DEFAULT '',
ADD COLUMN IF NOT EXISTS prefecture TEXT NOT NULL DEFAULT '',
ADD COLUMN IF NOT EXISTS dating_reason VARCHAR(100) NOT NULL DEFAULT '';

UPDATE users
SET
    birth_date = COALESCE(birth_date, CURRENT_DATE - make_interval(years => GREATEST(age, 18))),
    country = COALESCE(country, ''),
    prefecture = COALESCE(prefecture, ''),
    dating_reason = COALESCE(NULLIF(LEFT(bio, 100), ''), '')
WHERE birth_date IS NULL
   OR country IS NULL
   OR prefecture IS NULL
   OR dating_reason IS NULL;

ALTER TABLE users
ALTER COLUMN birth_date SET NOT NULL;
