-- IDS projekt 2022
-- Cast 2 - SQL skript pro vytvoření objektů schématu databáze
-- Autor: xmrkva04 & xstrel03

-- Drop:

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

-- Create:

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
    "cislo_op" NUMBER(10) DEFAULT NULL
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

-- Insert:

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
INSERT INTO "zakaznik" ("narodnost", "jmeno", "prijmeni", "cislo_op")
    VALUES ('PL', 'Jan', 'Kowalski', 8329647209);
INSERT INTO "zakaznik" ("narodnost", "jmeno", "prijmeni", "cislo_op")
    VALUES ('HU', 'János', 'Kovács', 4749234231);
INSERT INTO "zakaznik" ("narodnost", "jmeno", "prijmeni", "cislo_op")
    VALUES ('SK', 'Ján', 'Novák', 6385653214);

INSERT INTO "let" ("skutecny_cas_odletu", "skutecny_cas_pristani", "poznamka", "letovy_rezim_letu", "letadlo_seriove_cislo")
    VALUES ('10:00', '11:00', 'porucha motoru', 1, 6057511439);
INSERT INTO "let" ("skutecny_cas_odletu", "skutecny_cas_pristani", "letovy_rezim_letu", "letadlo_seriove_cislo")
    VALUES ('10:00', '11:00', 2, 1975346982);
INSERT INTO "let" ("skutecny_cas_odletu", "skutecny_cas_pristani", "letovy_rezim_letu", "letadlo_seriove_cislo")
    VALUES ('13:00', '15:00', 3, 8532190546);
INSERT INTO "let" ("skutecny_cas_odletu", "skutecny_cas_pristani", "poznamka", "letovy_rezim_letu", "letadlo_seriove_cislo")
    VALUES ('13:00', '15:00', 'pilot umrel', 1, 1975346982);

INSERT INTO "kosik" ("celkova_cena", "cas_expirace", "stav_uhrady", "zakaznik_rezervoval_id", "na_datum")
    VALUES (8313, TO_DATE('2023-03-24','YYYY-MM-DD'), 'ZPRACOVAVANI', 4, TO_DATE('2023-03-29','YYYY-MM-DD'));
INSERT INTO "kosik" ("celkova_cena", "cas_expirace", "stav_uhrady", "zakaznik_rezervoval_id", "na_datum")
    VALUES (3123, TO_DATE('2023-03-26','YYYY-MM-DD'), 'UHRAZENO', 1, TO_DATE('2023-03-27','YYYY-MM-DD'));
INSERT INTO "kosik" ("celkova_cena", "cas_expirace", "stav_uhrady", "zakaznik_rezervoval_id", "na_datum")
    VALUES (42384, TO_DATE('2023-03-22','YYYY-MM-DD'), 'NEUHRAZENO', 3, TO_DATE('2023-03-28','YYYY-MM-DD'));

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
