-- IDS projekt 2022
-- Cast 2 - SQL skript pro vytvoření objektů schématu databáze
-- Autor: xmrkva04 & xstrel03

-- Drop:

-- DROP TABLE "spolecnost";

-- DROP TABLE "letadlo";

-- DROP TABLE "let";

-- DROP TABLE "letovy_rezim";

DROP TABLE "letiste";

DROP TABLE "kosik";

DROP TABLE "datum";

DROP TABLE "zakaznik";

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

CREATE TABLE "zakaznik" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "narodnost" VARCHAR(2) NOT NULL
        CHECK ( LENGTH("narodnost") = 2 ),
    "jmeno" VARCHAR(100) NOT NULL,
    "prijmeni" VARCHAR(100) NOT NULL
);

CREATE TABLE "kosik" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "celkova_cena" INT NOT NULL,
    "zakaznik_id" INT NOT NULL,
    CONSTRAINT "kosik_zakaznik_id_fk"
		FOREIGN KEY ("zakaznik_id") REFERENCES "zakaznik" ("id")
);


CREATE TABLE "datum" (
    "datum" DATE NOT NULL PRIMARY KEY
        CHECK ( "datum" >= TO_DATE('1970/01/01', 'yyyy/mm/dd') )
);

-- Insert:
--
-- INSERT INTO "letiste" ("kod", "zeme", "mesto", "nazev")
-- VALUES ('BRQ', 'CZ', 'Brno', 'Tuřany');
--
-- INSERT INTO "letiste" ("kod", "zeme", "mesto", "nazev")
-- VALUES ('PRG', 'CZ', 'Prague', 'Letiště Václava Havla');
--
--
-- INSERT INTO "datum" ("datum")
-- VALUES (TO_DATE('2023-03-25', 'yyyy/mm/dd'));
--
-- INSERT INTO "datum" ("datum")
-- VALUES (TO_DATE('2023-03-24', 'yyyy/mm/dd'));
--
-- INSERT INTO "datum" ("datum")
-- VALUES (TO_DATE('2023-03-23', 'yyyy/mm/dd'));