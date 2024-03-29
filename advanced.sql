-- IDS projekt 2023
-- Cast 4 - SQL skript pro vytvoření pokročilých objektů schématu databáze
-- Autor: xmrkva04 & xstrel03

--------- Drop ---------

ALTER TABLE "letadlo" DROP CONSTRAINT "fk_letadlo_spolecnost_id";
ALTER TABLE "letovy_rezim" DROP CONSTRAINT "fk_letovy_rezim_misto_priletu";
ALTER TABLE "letovy_rezim" DROP CONSTRAINT "fk_letovy_rezim_misto_odletu";
ALTER TABLE "let" DROP CONSTRAINT "fk_let_letovy_rezim_letu";
ALTER TABLE "let" DROP CONSTRAINT "fk_let_letadlo_seriove_cislo";
ALTER TABLE "letovy_rezim_aktivni_v_datum" DROP CONSTRAINT "fk_letovy_rezim_aktivni_v_datum_letovy_rezim_id";
ALTER TABLE "letovy_rezim_aktivni_v_datum" DROP CONSTRAINT "fk_letovy_rezim_aktivni_v_datum_datum_datum";
ALTER TABLE "kosik" DROP CONSTRAINT "fk_kosik_zakaznik_rezervoval_id";
ALTER TABLE "kosik" DROP CONSTRAINT "fk_kosik_na_datum";
ALTER TABLE "kosik_pro_pasazery" DROP CONSTRAINT "fk_kosik_pro_pasazery_kosik_id";
ALTER TABLE "kosik_pro_pasazery" DROP CONSTRAINT "fk_kosik_pro_pasazery_pasazer_id";
ALTER TABLE "kosik_rezervuje_let" DROP CONSTRAINT "fk_kosik_rezervuje_let_kosik_id";
ALTER TABLE "kosik_rezervuje_let" DROP CONSTRAINT "fk_kosik_rezervuje_let_let_id";

DROP TABLE "spolecnost";
DROP TABLE "letadlo";
DROP TABLE "letiste";
DROP TABLE "letovy_rezim";
DROP TABLE "let";
DROP TABLE "datum";
DROP TABLE "zakaznik";
DROP TABLE "letovy_rezim_aktivni_v_datum";
DROP TABLE "kosik";
DROP TABLE "kosik_pro_pasazery";
DROP TABLE "kosik_rezervuje_let";

DROP INDEX "letovy_rezim_index";

DROP MATERIALIZED VIEW "zakaznici";

--------- Vytvoreni tabulek ---------

CREATE TABLE "spolecnost" (
    "id" VARCHAR(3) NOT NULL PRIMARY KEY,
        CHECK ( LENGTH("id") <= 3 ),
        CHECK ( LENGTH("id") >= 2 ),
    "nazev" VARCHAR(100) DEFAULT NULL
);

-- Oproti ER diagramu je seriove cislo letadla unikatni v ramci celeho systemu.
-- 1 letadlo muze byt nasazeno na 0..n letu.
CREATE TABLE "letadlo" (
    "seriove_cislo" INT NOT NULL PRIMARY KEY,
    "typ" VARCHAR(100) DEFAULT NULL,
    "spolecnost_id" VARCHAR(3) NOT NULL,

    CONSTRAINT "fk_letadlo_spolecnost_id"
        FOREIGN KEY ("spolecnost_id")
        REFERENCES "spolecnost" ("id")
        ON DELETE SET NULL
);

CREATE TABLE "letiste" (
    "kod" VARCHAR(3) NOT NULL PRIMARY KEY
        CHECK ( LENGTH("kod") = 3 ),
    "zeme" VARCHAR(2) NOT NULL
        CHECK ( LENGTH("zeme") = 2 ),
    "mesto" VARCHAR(100) NOT NULL,
    "nazev" VARCHAR(100) NOT NULL
);

-- Oproti ER diagramu je misto priletu a odletu presunuto do letoveho rezimu,
-- letovy rezim dodrzuje 0..n letu.
CREATE TABLE "letovy_rezim" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "pravidelny_cas_priletu" VARCHAR(5) NOT NULL,
    "pravidelny_cas_odletu" VARCHAR(5) NOT NULL,
    "misto_priletu" VARCHAR(3) NOT NULL,
    "misto_odletu" VARCHAR(3) NOT NULL,

    CONSTRAINT "fk_letovy_rezim_misto_priletu"
        FOREIGN KEY ("misto_priletu")
        REFERENCES "letiste" ("kod")
        ON DELETE SET NULL,

    CONSTRAINT "fk_letovy_rezim_misto_odletu"
        FOREIGN KEY ("misto_odletu")
        REFERENCES "letiste" ("kod")
        ON DELETE SET NULL
);

-- Oproti ER diagramu je cislo letu unikatni v ramci celeho systemu, misto
-- priletu a odletu je presunuto k letovemu rezimu, let dodrzuje 1 letovy rezim,
-- na letu je nasazeno 1 letadlo.
CREATE TABLE "let" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "skutecny_cas_odletu" VARCHAR(5) DEFAULT NULL,
    "skutecny_cas_pristani" VARCHAR(5) DEFAULT NULL,
    "skutecne_trvani_letu" VARCHAR(100) DEFAULT NULL,
    "poznamka" VARCHAR(100) DEFAULT NULL,
    "letovy_rezim_letu" INT NOT NULL,
    "letadlo_seriove_cislo" INT NOT NULL,

    CONSTRAINT "fk_let_letovy_rezim_letu"
        FOREIGN KEY ("letovy_rezim_letu")
        REFERENCES "letovy_rezim" ("id")
        ON DELETE SET NULL,

    CONSTRAINT "fk_let_letadlo_seriove_cislo"
        FOREIGN KEY ("letadlo_seriove_cislo")
        REFERENCES "letadlo" ("seriove_cislo")
        ON DELETE SET NULL
);

CREATE TABLE "datum" (
    "datum" DATE NOT NULL PRIMARY KEY
);

CREATE TABLE "letovy_rezim_aktivni_v_datum" (
    "letovy_rezim_id" INT NOT NULL,
    "datum_datum" DATE NOT NULL,

    CONSTRAINT "pk_letovy_rezim_aktivni_v_datum"
        PRIMARY KEY ("letovy_rezim_id", "datum_datum"),

    CONSTRAINT "fk_letovy_rezim_aktivni_v_datum_letovy_rezim_id"
        FOREIGN KEY ("letovy_rezim_id")
        REFERENCES "letovy_rezim" ("id")
        ON DELETE SET NULL,

    CONSTRAINT "fk_letovy_rezim_aktivni_v_datum_datum_datum"
        FOREIGN KEY ("datum_datum")
        REFERENCES "datum" ("datum")
        ON DELETE SET NULL
);

-- Oproti ER diagramu je pro zakazniky bez RC pouzito cislo OP
CREATE TABLE "zakaznik" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "narodnost" VARCHAR(2) NOT NULL
        CHECK ( LENGTH("narodnost") = 2 ),
    "jmeno" VARCHAR(100) NOT NULL,
    "prijmeni" VARCHAR(100) NOT NULL,
    "rodne_cislo" NUMBER(10) DEFAULT NULL,
    "cislo_op" NUMBER(10) DEFAULT NULL,
    "vek" NUMBER(2) DEFAULT NULL,
    "vekova_kategorie" VARCHAR(10)
);

ALTER TABLE "zakaznik" ADD CONSTRAINT "ck_zakaznik_rc_delitelne"
    CHECK ( (MOD("rodne_cislo", 11) = 0) OR ("rodne_cislo" IS NULL) );

CREATE TABLE "kosik" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "celkova_cena" INT NOT NULL,
    "cas_expirace" TIMESTAMP NOT NULL,
    "stav_uhrady" VARCHAR(20) NOT NULL,
        CHECK("stav_uhrady" IN ('NEUHRAZENO', 'ZPRACOVAVANI', 'UHRAZENO')),
    "zakaznik_rezervoval_id" INT NOT NULL,
    "na_datum" DATE NOT NULL,

    CONSTRAINT "fk_kosik_zakaznik_rezervoval_id"
        FOREIGN KEY ("zakaznik_rezervoval_id")
        REFERENCES "zakaznik" ("id")
        ON DELETE CASCADE,

    CONSTRAINT "fk_kosik_na_datum"
        FOREIGN KEY ("na_datum")
        REFERENCES "datum" ("datum")
        ON DELETE CASCADE
);

ALTER TABLE "kosik" ADD CONSTRAINT "ck_kosik_celkova_cena"
    CHECK ( "celkova_cena" >= 0 );

CREATE TABLE "kosik_pro_pasazery" (
    "kosik_id" INT NOT NULL,
    "pasazer_id" INT,

    CONSTRAINT "pk_kosik_pro_pasazery"
        PRIMARY KEY ("kosik_id", "pasazer_id"),

    CONSTRAINT "fk_kosik_pro_pasazery_kosik_id"
        FOREIGN KEY ("kosik_id")
        REFERENCES "kosik" ("id")
        ON DELETE CASCADE,

    CONSTRAINT "fk_kosik_pro_pasazery_pasazer_id"
        FOREIGN KEY ("pasazer_id")
        REFERENCES "zakaznik" ("id")
        ON DELETE CASCADE
);

CREATE TABLE "kosik_rezervuje_let" (
    "kosik_id" INT NOT NULL,
    "let_id" INT,

    CONSTRAINT "pk_kosik_rezervuje_let"
        PRIMARY KEY ("kosik_id", "let_id"),

    CONSTRAINT "fk_kosik_rezervuje_let_kosik_id"
        FOREIGN KEY ("kosik_id")
        REFERENCES "kosik" ("id")
        ON DELETE CASCADE,

    CONSTRAINT "fk_kosik_rezervuje_let_let_id"
        FOREIGN KEY ("let_id")
        REFERENCES "let" ("id")
        ON DELETE CASCADE
);

--------- Netrivialni triggery ---------

-- Vypocet letove doby letu
CREATE OR REPLACE TRIGGER "skutecne_trvani_letu"
    BEFORE INSERT ON "let"
    FOR EACH ROW
DECLARE
    odlet TIMESTAMP;
    pristani TIMESTAMP;
    trvani INTERVAL DAY TO SECOND;
    doba_char VARCHAR(100);
BEGIN
    odlet := TO_TIMESTAMP(:NEW."skutecny_cas_odletu", 'HH24:MI');
    pristani := TO_TIMESTAMP(:NEW."skutecny_cas_pristani", 'HH24:MI');
    trvani := pristani - odlet;
    doba_char := TO_CHAR(trvani, 'HH24:MI');
    :NEW."skutecne_trvani_letu" := SUBSTR(doba_char, 9, 2) || ':' || SUBSTR(trvani, 11, 2);
END;

-- Vypocet veku zakaznika a zarazeni do vekove kategorie
CREATE OR REPLACE TRIGGER "vek_zakaznika"
    BEFORE INSERT ON "zakaznik"
    FOR EACH ROW
DECLARE
    rok_narozeni NUMBER(2);
    cely_rok_narozeni NUMBER(4);
    vek NUMBER(2);
BEGIN
    IF :NEW."rodne_cislo" IS NOT NULL THEN
        rok_narozeni := SUBSTR(:NEW."rodne_cislo", 1, 2);

        IF rok_narozeni > 23 THEN
            cely_rok_narozeni := 1900 + rok_narozeni;
        ELSE
            cely_rok_narozeni := 2000 + rok_narozeni;
        END IF;

        vek := EXTRACT(YEAR FROM SYSDATE) - cely_rok_narozeni;
        :NEW."vek" := vek;

        IF vek < 13 THEN
            :NEW."vekova_kategorie" := 'dite';
        ELSIF vek < 19 THEN
            :NEW."vekova_kategorie" := 'junior';
        ELSIF vek < 26 THEN
            :NEW."vekova_kategorie" := 'student';
        ELSIF vek < 65 THEN
            :NEW."vekova_kategorie" := 'dospely';
        ELSE
            :NEW."vekova_kategorie" := 'senior';
        END IF;
    END IF;
END;

--------- Vlozeni hodnot ---------

INSERT INTO "letiste" ("kod", "zeme", "mesto", "nazev")
    VALUES ('PRG', 'CZ', 'Praha', 'Václav Havel Airport Prague');
INSERT INTO "letiste" ("kod", "zeme", "mesto", "nazev")
    VALUES ('BRQ', 'CZ', 'Brno', 'Brno-Tuřany Airport');
INSERT INTO "letiste" ("kod", "zeme", "mesto", "nazev")
    VALUES ('OSR', 'CZ', 'Ostrava', 'Ostrava Leoš Janáček Airport');
INSERT INTO "letiste" ("kod", "zeme", "mesto", "nazev")
    VALUES ('WAW', 'PL', 'Warszawa', 'Warsaw Chopin Airport');
INSERT INTO "letiste" ("kod", "zeme", "mesto", "nazev")
    VALUES ('BUD', 'HU', 'Budapest', 'Budapest Ferenc Liszt International Airport');
INSERT INTO "letiste" ("kod", "zeme", "mesto", "nazev")
    VALUES ('BTS', 'SK', 'Bratislava', 'M. R. Štefánik Airport');
INSERT INTO "letiste" ("kod", "zeme", "mesto", "nazev")
    VALUES ('VIE', 'AT', 'Wien', 'Vienna International Airport');
INSERT INTO "letiste" ("kod", "zeme", "mesto", "nazev")
    VALUES ('MUC', 'DE', 'München', 'Munich Airport');
INSERT INTO "letiste" ("kod", "zeme", "mesto", "nazev")
    VALUES ('LHR', 'GB', 'London', 'London Heathrow Airport');
INSERT INTO "letiste" ("kod", "zeme", "mesto", "nazev")
    VALUES ('CDG', 'FR', 'Paris', 'Charles de Gaulle Airport');

INSERT INTO "spolecnost" ("id", "nazev")
    VALUES ('RYR', 'Ryanair');
INSERT INTO "spolecnost" ("id", "nazev")
    VALUES ('EZY', 'easyJet');
INSERT INTO "spolecnost" ("id", "nazev")
    VALUES ('CSA', 'Czech Airlines');
INSERT INTO "spolecnost" ("id", "nazev")
    VALUES ('BAW', 'British Airways');
INSERT INTO "spolecnost" ("id", "nazev")
    VALUES ('AA', 'American Airlines');

INSERT INTO "letadlo" ("seriove_cislo", "typ", "spolecnost_id")
    VALUES (6057511439, 'Boeing 737', 'RYR');
INSERT INTO "letadlo" ("seriove_cislo", "typ", "spolecnost_id")
    VALUES (4892178964, 'Boeing 737', 'CSA');
INSERT INTO "letadlo" ("seriove_cislo", "typ", "spolecnost_id")
    VALUES (6985412385, 'Boeing 737', 'CSA');
INSERT INTO "letadlo" ("seriove_cislo", "typ", "spolecnost_id")
    VALUES (8532190546, 'Airbus A320', 'EZY');
INSERT INTO "letadlo" ("seriove_cislo", "typ", "spolecnost_id")
    VALUES (4209835716, 'Boeing 787 Dreamliner', 'RYR');
INSERT INTO "letadlo" ("seriove_cislo", "typ", "spolecnost_id")
    VALUES (8675493210, 'Boeing 777', 'CSA');
INSERT INTO "letadlo" ("seriove_cislo", "typ", "spolecnost_id")
    VALUES (1975346982, 'Airbus A320', 'EZY');

INSERT INTO "letovy_rezim" ("pravidelny_cas_odletu", "pravidelny_cas_priletu", "misto_odletu", "misto_priletu")
    VALUES ('10:00', '11:00', 'PRG', 'BUD');
INSERT INTO "letovy_rezim" ("pravidelny_cas_odletu", "pravidelny_cas_priletu", "misto_odletu", "misto_priletu")
    VALUES ('07:00', '15:00', 'PRG', 'CDG');
INSERT INTO "letovy_rezim" ("pravidelny_cas_odletu", "pravidelny_cas_priletu", "misto_odletu", "misto_priletu")
    VALUES ('12:00', '13:30', 'BRQ', 'LHR');
INSERT INTO "letovy_rezim" ("pravidelny_cas_odletu", "pravidelny_cas_priletu", "misto_odletu", "misto_priletu")
    VALUES ('14:00', '15:00', 'OSR', 'CDG');
INSERT INTO "letovy_rezim" ("pravidelny_cas_odletu", "pravidelny_cas_priletu", "misto_odletu", "misto_priletu")
    VALUES ('16:00', '18:30', 'WAW', 'MUC');
INSERT INTO "letovy_rezim" ("pravidelny_cas_odletu", "pravidelny_cas_priletu", "misto_odletu", "misto_priletu")
    VALUES ('18:00', '20:15', 'BRQ', 'CDG');

INSERT INTO "datum" ("datum")
    VALUES (TO_DATE('2023-03-26','YYYY-MM-DD'));
INSERT INTO "datum" ("datum")
    VALUES (TO_DATE('2023-03-27','YYYY-MM-DD'));
INSERT INTO "datum" ("datum")
    VALUES (TO_DATE('2023-03-28','YYYY-MM-DD'));
INSERT INTO "datum" ("datum")
    VALUES (TO_DATE('2023-03-29','YYYY-MM-DD'));
INSERT INTO "datum" ("datum")
    VALUES (TO_DATE('2023-03-30','YYYY-MM-DD'));

INSERT INTO "letovy_rezim_aktivni_v_datum" ("letovy_rezim_id", "datum_datum")
    VALUES (3, TO_DATE('2023-03-26','YYYY-MM-DD'));
INSERT INTO "letovy_rezim_aktivni_v_datum" ("letovy_rezim_id", "datum_datum")
    VALUES (3, TO_DATE('2023-03-27','YYYY-MM-DD'));
INSERT INTO "letovy_rezim_aktivni_v_datum" ("letovy_rezim_id", "datum_datum")
    VALUES (1, TO_DATE('2023-03-29','YYYY-MM-DD'));
INSERT INTO "letovy_rezim_aktivni_v_datum" ("letovy_rezim_id", "datum_datum")
    VALUES (2, TO_DATE('2023-03-27','YYYY-MM-DD'));


INSERT INTO "zakaznik" ("narodnost", "jmeno", "prijmeni", "rodne_cislo")
    VALUES ('CZ', 'Petr', 'Novák', 7451247837);
INSERT INTO "zakaznik" ("narodnost", "jmeno", "prijmeni", "rodne_cislo")
    VALUES ('CZ', 'Jan', 'Novotný', 8732129230);
INSERT INTO "zakaznik" ("narodnost", "jmeno", "prijmeni", "rodne_cislo")
    VALUES ('CZ', 'Markéta', 'Novotná', 1102676597);
INSERT INTO "zakaznik" ("narodnost", "jmeno", "prijmeni", "cislo_op")
    VALUES ('PL', 'Jan', 'Kowalski', 8329647209);
INSERT INTO "zakaznik" ("narodnost", "jmeno", "prijmeni", "cislo_op")
    VALUES ('GB', 'Jan', 'Obbermaier', 5789567890);
INSERT INTO "zakaznik" ("narodnost", "jmeno", "prijmeni", "cislo_op")
    VALUES ('HU', 'János', 'Kovács', 4749234231);
INSERT INTO "zakaznik" ("narodnost", "jmeno", "prijmeni", "cislo_op")
    VALUES ('SK', 'Ján', 'Novák', 6385653214);
INSERT INTO "zakaznik" ("narodnost", "jmeno", "prijmeni", "cislo_op")
    VALUES ('GR', 'Dimitris', 'Alanas', 1579893154);

INSERT INTO "let" ("skutecny_cas_odletu", "skutecny_cas_pristani", "poznamka", "letovy_rezim_letu", "letadlo_seriove_cislo")
    VALUES ('11:00', '12:00', 'porucha motoru', 1, 6057511439);
INSERT INTO "let" ("skutecny_cas_odletu", "skutecny_cas_pristani", "letovy_rezim_letu", "letadlo_seriove_cislo")
    VALUES ('7:00', '15:00', 2, 1975346982);
INSERT INTO "let" ("skutecny_cas_odletu", "skutecny_cas_pristani", "letovy_rezim_letu", "letadlo_seriove_cislo")
    VALUES ('13:00', '15:00', 3, 8532190546);
INSERT INTO "let" ("skutecny_cas_odletu", "skutecny_cas_pristani", "poznamka", "letovy_rezim_letu", "letadlo_seriove_cislo")
    VALUES ('13:00', '15:00', 'pilot umrel', 1, 1975346982);

INSERT INTO "kosik" ("celkova_cena", "cas_expirace", "stav_uhrady", "zakaznik_rezervoval_id", "na_datum")
    VALUES (13465, TO_DATE('2023-03-24','YYYY-MM-DD'), 'NEUHRAZENO', 4, TO_DATE('2023-03-28','YYYY-MM-DD'));
INSERT INTO "kosik" ("celkova_cena", "cas_expirace", "stav_uhrady", "zakaznik_rezervoval_id", "na_datum")
    VALUES (3123, TO_DATE('2023-03-26','YYYY-MM-DD'), 'UHRAZENO', 1, TO_DATE('2023-03-27','YYYY-MM-DD'));
INSERT INTO "kosik" ("celkova_cena", "cas_expirace", "stav_uhrady", "zakaznik_rezervoval_id", "na_datum")
    VALUES (42384, TO_DATE('2023-03-22','YYYY-MM-DD'), 'NEUHRAZENO', 3, TO_DATE('2023-03-28','YYYY-MM-DD'));
INSERT INTO "kosik" ("celkova_cena", "cas_expirace", "stav_uhrady", "zakaznik_rezervoval_id", "na_datum")
    VALUES (5555, TO_DATE('2023-03-24','YYYY-MM-DD'), 'ZPRACOVAVANI', 4, TO_DATE('2023-03-29','YYYY-MM-DD'));
INSERT INTO "kosik" ("celkova_cena", "cas_expirace", "stav_uhrady", "zakaznik_rezervoval_id", "na_datum")
    VALUES (6453, TO_DATE('2023-03-24','YYYY-MM-DD'), 'UHRAZENO', 4, TO_DATE('2023-03-30','YYYY-MM-DD'));

INSERT INTO "kosik_rezervuje_let" ("kosik_id", "let_id")
    VALUES (1, 2);
INSERT INTO "kosik_rezervuje_let" ("kosik_id", "let_id")
    VALUES (1, 3);
INSERT INTO "kosik_rezervuje_let" ("kosik_id", "let_id")
    VALUES (1, 4);
INSERT INTO "kosik_rezervuje_let" ("kosik_id", "let_id")
    VALUES (2, 2);
INSERT INTO "kosik_rezervuje_let" ("kosik_id", "let_id")
    VALUES (3, 2);
INSERT INTO "kosik_rezervuje_let" ("kosik_id", "let_id")
    VALUES (3, 1);
INSERT INTO "kosik_rezervuje_let" ("kosik_id", "let_id")
    VALUES (4, 4);
INSERT INTO "kosik_rezervuje_let" ("kosik_id", "let_id")
    VALUES (5, 1);

INSERT INTO "kosik_pro_pasazery" ("kosik_id", "pasazer_id")
    VALUES (1, 1);
INSERT INTO "kosik_pro_pasazery" ("kosik_id", "pasazer_id")
    VALUES (1, 2);
INSERT INTO "kosik_pro_pasazery" ("kosik_id", "pasazer_id")
    VALUES (2, 3);
INSERT INTO "kosik_pro_pasazery" ("kosik_id", "pasazer_id")
    VALUES (2, 4);
INSERT INTO "kosik_pro_pasazery" ("kosik_id", "pasazer_id")
    VALUES (3, 5);
INSERT INTO "kosik_pro_pasazery" ("kosik_id", "pasazer_id")
    VALUES (4, 4);
INSERT INTO "kosik_pro_pasazery" ("kosik_id", "pasazer_id")
    VALUES (5, 4);

--------- Dotazy SELECT ---------

-- Letadla provozovane firmou Ryanair - spojeni dvou tabulek
SELECT * FROM "letadlo" INNER JOIN "spolecnost" ON "letadlo"."spolecnost_id" = "spolecnost"."id" WHERE "id" = 'RYR';

-- Nazev spolecnosti ktera vlastni letadlo Boeing 737 - spojeni dvou tabulek
SELECT DISTINCT "nazev" FROM "letadlo" INNER JOIN "spolecnost" ON "letadlo"."spolecnost_id" = "spolecnost"."id" WHERE "typ" = 'Boeing 737';

-- Porovnani skutecneho casu odletu a pravidelneho casu odletu letadla 1975346982 leticich z Prahy (+ duvod spozdeni v poznamce) - spojeni tri tabulek
SELECT "pravidelny_cas_odletu","skutecny_cas_odletu","poznamka","datum_datum","misto_odletu","misto_priletu","letadlo_seriove_cislo"
FROM "let"
JOIN "letovy_rezim" ON "let"."letovy_rezim_letu" = "letovy_rezim"."id"
JOIN "letovy_rezim_aktivni_v_datum" ON "letovy_rezim"."id" = "letovy_rezim_aktivni_v_datum"."letovy_rezim_id"
WHERE "misto_odletu" = 'PRG' AND "letadlo_seriove_cislo"='1975346982';

-- Zobrazi id a jmena zakazniku, kteri maji vic jak jednou letenku - dotaz s klauzuli GROUP BY a agregacni funkci
SELECT "jmeno","prijmeni","zakaznik"."id",COUNT("zakaznik"."id")
FROM "zakaznik"
JOIN "kosik" ON "zakaznik"."id" = "kosik"."zakaznik_rezervoval_id"
JOIN "kosik_rezervuje_let" ON "kosik"."id" = "kosik_rezervuje_let"."kosik_id"
GROUP BY "jmeno","prijmeni","zakaznik"."id"
HAVING COUNT("zakaznik"."id") > 1;

-- Zobrazi nazvy spolecnosti, jejich pocet letu z Prahy a seradi je sestupne - dotaz s klauzuli GROUP BY a agregacni funkci
SELECT "nazev", COUNT("misto_odletu") AS "pocet_letu_z_prahy"
FROM "spolecnost"
JOIN "letadlo" ON "letadlo"."spolecnost_id" = "spolecnost"."id"
JOIN "let" ON "let"."letadlo_seriove_cislo" = "letadlo"."seriove_cislo"
JOIN "letovy_rezim" ON "letovy_rezim"."id" = "let"."letovy_rezim_letu"
GROUP BY "nazev","misto_odletu"
HAVING "misto_odletu" = 'PRG'
ORDER BY "pocet_letu_z_prahy" DESC;

-- Zobrazi jmena zakazniku, jejichz cena letenek presahla 10000 - predikat EXISTS
SELECT "jmeno","prijmeni"
FROM "zakaznik"
WHERE EXISTS
(SELECT * FROM "kosik" WHERE "zakaznik"."id" = "kosik"."zakaznik_rezervoval_id" AND "celkova_cena" > 10000);

-- Zobrazi zakazniky, jejichz zeme nema v ramci databaze letiste
SELECT *
FROM "zakaznik"
WHERE "narodnost" NOT IN (SELECT "zeme" FROM "letiste");

-- Predvedeni triggeru "skutecne_trvani_letu" - vypocet skutecneho trvani letu
SELECT "id", "skutecny_cas_odletu", "skutecny_cas_pristani", "skutecne_trvani_letu"
FROM "let";

-- Predvedeni triggeru "vek_zakaznika"
SELECT "jmeno", "prijmeni", "rodne_cislo", "vek", "vekova_kategorie"
FROM "zakaznik"
WHERE "rodne_cislo" IS NOT NULL;

--------- Index a explain plan ---------

-- Vybrat lety odletajici z letiste v CZ s odletem po 10. hodine
-- cpu_cost = 32.461.436, io_cost = 9, total_cost=10.0
EXPLAIN PLAN FOR
    SELECT "id", "pravidelny_cas_odletu", "letiste_odlet"."kod", "letiste_odlet"."zeme",
           "pravidelny_cas_priletu", "letiste_prilet"."kod", "letiste_prilet"."zeme"
    FROM "letovy_rezim"
    JOIN "letiste" "letiste_prilet" ON "letovy_rezim"."misto_priletu" = "letiste_prilet"."kod"
    JOIN "letiste" "letiste_odlet" ON "letovy_rezim"."misto_odletu" = "letiste_odlet"."kod"
    WHERE "letiste_odlet"."zeme" = 'CZ'
    AND TO_DATE("pravidelny_cas_odletu", 'HH24:MI') > TO_DATE('10:00', 'HH24:MI')
    ORDER BY "pravidelny_cas_odletu";
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Vytvoreni indexu na sloupci "pravidelny_cas_odletu" tabulky "letovy_rezim"
CREATE INDEX "letovy_rezim_index" on "letovy_rezim" ("pravidelny_cas_odletu");

-- cpu_cost = 85.913, io_cost = 9, total_cost=10.0
EXPLAIN PLAN FOR
    SELECT "id", "pravidelny_cas_odletu", "letiste_odlet"."kod", "letiste_odlet"."zeme",
           "pravidelny_cas_priletu", "letiste_prilet"."kod", "letiste_prilet"."zeme"
    FROM "letovy_rezim"
    JOIN "letiste" "letiste_prilet" ON "letovy_rezim"."misto_priletu" = "letiste_prilet"."kod"
    JOIN "letiste" "letiste_odlet" ON "letovy_rezim"."misto_odletu" = "letiste_odlet"."kod"
    WHERE "letiste_odlet"."zeme" = 'CZ'
    AND TO_DATE("pravidelny_cas_odletu", 'HH24:MI') > TO_DATE('10:00', 'HH24:MI')
    ORDER BY "pravidelny_cas_odletu";
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--------- Netrivialni dotaz select s CASE a WITH ---------

-- Klasifikace objednavek na zaklade utracene castky a vypsani jejich poctu
WITH "klasifikace_objednavek" AS (
    SELECT "celkova_cena","zakaznik_rezervoval_id", "na_datum",
        CASE
            WHEN "celkova_cena" > 30000 THEN 'Velká útrata'
            WHEN "celkova_cena" > 10000 THEN 'Střední útrata'
            ELSE 'Malá útrata'
        END AS "klasifikace"
    FROM "kosik"
    )
SELECT "klasifikace", COUNT(*) as "pocet"
FROM "klasifikace_objednavek"
GROUP BY "klasifikace"
ORDER BY "klasifikace";

--------- Materializovany pohled ---------

CREATE MATERIALIZED VIEW "zakaznici" AS
SELECT "jmeno","prijmeni","zakaznik"."id",COUNT("zakaznik"."id") AS "pocet_letenek"
FROM "zakaznik"
JOIN "kosik" ON "zakaznik"."id" = "kosik"."zakaznik_rezervoval_id"
JOIN "kosik_rezervuje_let" ON "kosik"."id" = "kosik_rezervuje_let"."kosik_id"
GROUP BY "jmeno","prijmeni","zakaznik"."id";

-- Vypis pred zmenou zakaznika
SELECT * FROM "zakaznici";

UPDATE "zakaznik" SET "prijmeni" = 'Ananas' WHERE "cislo_op" = 8329647209;

-- Vypis po zmene - materialized view se neaktualizuje
SELECT * FROM "zakaznici";

--------- Netrivialni ulozene procedury ---------

-- Procedura vypisujici seznam kosiku daneho zakaznika
CREATE OR REPLACE PROCEDURE "vypis_kosiku" ("p_zakaznik_id" INT)
AS
    CURSOR "c_kosik" IS
    SELECT * FROM "kosik" WHERE "zakaznik_rezervoval_id" = "p_zakaznik_id";
    "v_kosik_row" "kosik"%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Informace o košících uživatele ' || "p_zakaznik_id");
    OPEN "c_kosik";
    LOOP
        FETCH "c_kosik" INTO "v_kosik_row";
        EXIT WHEN "c_kosik"%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE( '  Celková cena letenek CZK ' || "v_kosik_row"."celkova_cena" || ', ve stavu ' || "v_kosik_row"."stav_uhrady" || '. Na datum: ' || "v_kosik_row"."na_datum" || '.');
    END LOOP;
    CLOSE "c_kosik";
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Žádné záznamy nebyly nalezeny');
END;

BEGIN "vypis_kosiku"('1'); END;
BEGIN "vypis_kosiku"('4'); END;

-- Procedura vypisujici historii letadla pro servisni ucely
CREATE OR REPLACE PROCEDURE "letadlo_informace" ("p_letadlo_seriove_cislo" INT)
AS
  CURSOR "c_lety" IS
    SELECT "let"."id" as "let_id", "skutecny_cas_odletu", "skutecny_cas_pristani",
            "skutecne_trvani_letu", "poznamka", "typ", "spolecnost_id","misto_odletu",
            "misto_priletu"
    FROM "let"
    JOIN "letadlo" ON "letadlo"."seriove_cislo" = "let"."letadlo_seriove_cislo"
    JOIN "letovy_rezim" ON "let"."letovy_rezim_letu" = "letovy_rezim"."id"
    WHERE "letadlo"."seriove_cislo" = "p_letadlo_seriove_cislo";
    "v_lety_row" "c_lety"%ROWTYPE;
    lety NUMBER;
    doba NUMBER;
    prumer NUMBER;
BEGIN
    OPEN "c_lety";
    FETCH "c_lety" INTO "v_lety_row";
    DBMS_OUTPUT.PUT_LINE('Servisni informace o letadle ' || "p_letadlo_seriove_cislo" || ', Typ ' || "v_lety_row"."typ"
                        || ', Provozovano aerolinkou ' || "v_lety_row"."spolecnost_id" || '.');
    lety := 0;
    doba := 0.0;
    LOOP
        EXIT WHEN "c_lety"%NOTFOUND;
        lety := lety + 1;
        doba := doba + TO_NUMBER(SUBSTR("v_lety_row"."skutecne_trvani_letu", 1, INSTR("v_lety_row"."skutecne_trvani_letu", ':')-1))
                    + TO_NUMBER(SUBSTR("v_lety_row"."skutecne_trvani_letu", INSTR("v_lety_row"."skutecne_trvani_letu", ':')+1))/60;
        DBMS_OUTPUT.PUT_LINE( '  ID letu: ' || "v_lety_row"."let_id" || '. ' ||
                            'Odlet z ' || "v_lety_row"."misto_odletu" || ' v ' || "v_lety_row"."skutecny_cas_odletu" ||
                            ', Prilet do ' || "v_lety_row"."misto_priletu" || ' v ' || "v_lety_row"."skutecny_cas_pristani" ||
                            ', Doba letu ' || "v_lety_row"."skutecne_trvani_letu");

        FETCH "c_lety" INTO "v_lety_row";
    END LOOP;
    CLOSE "c_lety";
    prumer := doba / lety;
    DBMS_OUTPUT.PUT_LINE('Celkem letu: ' || lety || ', Celkova doba letu: ' || doba || ' hodin, Prumerne trvani letu: ' || prumer || ' hodin.');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Žádné záznamy nebyly nalezeny');
        WHEN ZERO_DIVIDE THEN
            DBMS_OUTPUT.PUT_LINE('ERROR - Dělení nulou');
END;

BEGIN "letadlo_informace"('1975346982'); END;
BEGIN "letadlo_informace"('6057511439'); END;

--------- Definice pristupovych prav ---------

GRANT ALL ON "spolecnost" TO xmrkva04;
GRANT ALL ON "letadlo" TO xmrkva04;
GRANT ALL ON "letiste" TO xmrkva04;
GRANT ALL ON "letovy_rezim" TO xmrkva04;
GRANT ALL ON "let" TO xmrkva04;
GRANT ALL ON "datum" TO xmrkva04;
GRANT ALL ON "zakaznik" TO xmrkva04;
GRANT ALL ON "kosik" TO xmrkva04;
GRANT ALL ON "letovy_rezim_aktivni_v_datum" TO xmrkva04;
GRANT ALL ON "kosik_pro_pasazery" TO xmrkva04;
GRANT ALL ON "kosik_rezervuje_let" TO xmrkva04;

GRANT EXECUTE ON "vypis_kosiku" to xmrkva04;
GRANT EXECUTE ON "letadlo_informace" to xmrkva04;

GRANT ALL ON "zakaznici" to xmrkva04;
