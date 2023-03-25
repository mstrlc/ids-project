-- IDS projekt 2022
-- Cast 2 - SQL skript pro vytvoření objektů schématu databáze
-- Autor: xmrkva04 & xstrel03

-- Drop:

-- DROP TABLE "spolecnost";

-- DROP TABLE "letadlo";

-- DROP TABLE "let";

-- DROP TABLE "letovy_rezim";

DROP TABLE "letiste";

-- DROP TABLE "kosik";

-- DROP TABLE "datum";

-- DROP TABLE "zakaznik";

-- Create:

-- CREATE TABLE "spolecnost" (
-- );
--
-- CREATE TABLE "letadlo" (
-- );
--
-- CREATE TABLE "let" (
--
-- );

-- CREATE TABLE "letovy_rezim" (
-- );

CREATE TABLE "letiste" (
    "kod" VARCHAR(3) NOT NULL PRIMARY KEY
        CHECK ( LENGTH("kod") = 3 ),
    "zeme" VARCHAR(2) NOT NULL
        CHECK ( LENGTH("zeme") = 2 ),
    "mesto" VARCHAR(100) NOT NULL,
    "nazev" VARCHAR(100) NOT NULL
);

-- CREATE TABLE "kosik" (
-- );
--
-- CREATE TABLE "datum" (
-- );
--
-- CREATE TABLE "zakaznik" (
-- );

-- Insert:

INSERT INTO "letiste" ("kod", "zeme", "mesto", "nazev")
VALUES ('BRQ', 'CZ', 'Brno', 'Tuřany');

INSERT INTO "letiste" ("kod", "zeme", "mesto", "nazev")
VALUES ('PRG', 'CZ', 'Prague', 'Letiště Václava Havla')
