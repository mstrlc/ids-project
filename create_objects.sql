-- IDS projekt 2022
-- Cast 2 - SQL skript pro vytvoření objektů schématu databáze
-- Autor: xmrkva04 & xstrel03

-- Drop:

ALTER TABLE "letadlo" DROP CONSTRAINT "fk_letadlo_spolecnost_id";
ALTER TABLE "letovy_rezim" DROP CONSTRAINT "fk_letovy_rezim_misto_priletu";
ALTER TABLE "letovy_rezim" DROP CONSTRAINT "fk_letovy_rezim_misto_odletu";
ALTER TABLE "let" DROP CONSTRAINT "fk_let_letovy_rezim_letu";
ALTER TABLE "letadlo_leta_let" DROP CONSTRAINT "fk_letadlo_leta_let_letadlo_seriove_cislo";
ALTER TABLE "letadlo_leta_let" DROP CONSTRAINT "fk_letadlo_leta_let_let_id";
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
DROP TABLE "letadlo_leta_let";
DROP TABLE "datum";
DROP TABLE "zakaznik";
DROP TABLE "letovy_rezim_aktivni_v_datum";
DROP TABLE "kosik";
DROP TABLE "kosik_pro_pasazery";
DROP TABLE "kosik_rezervuje_let";

-- Create:

CREATE TABLE "spolecnost" (
    "id" VARCHAR(3) NOT NULL PRIMARY KEY,
    "jmeno" VARCHAR(100) DEFAULT NULL,
    CHECK ( LENGTH("id") = 3 )
);

-- Oproti ER diagramu je seriove cislo letadla unikatni v ramci celeho systemu.
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

-- Oproti ER diagramu je misto priletu a odletu presunuto do letoveho rezimu, letovy rezim dodrzuje 0..n letu. 
CREATE TABLE "letovy_rezim" (
    "id" VARCHAR(7) NOT NULL PRIMARY KEY,
    "pravidelny_cas_priletu" TIMESTAMP NOT NULL,
    "pravidelny_cas_odletu" TIMESTAMP NOT NULL,
    "misto_priletu" VARCHAR(3) NOT NULL,
    CONSTRAINT "fk_letovy_rezim_misto_priletu"
        FOREIGN KEY ("misto_priletu")
        REFERENCES "letiste" ("kod")
        ON DELETE SET NULL,
    "misto_odletu" VARCHAR(3) NOT NULL,
    CONSTRAINT "fk_letovy_rezim_misto_odletu"
        FOREIGN KEY ("misto_odletu")
        REFERENCES "letiste" ("kod")
        ON DELETE SET NULL
);

-- Oproti ER diagramu je cislo letu unikatni v ramci celeho systemu a misto priletu a odletu je presunuto k letovemu rezimu, let dodrzuje 1 letovy rezim.
CREATE TABLE "let" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "skutecny_cas_odletu" TIMESTAMP DEFAULT NULL,
    "skutecny_cas_pristani" TIMESTAMP DEFAULT NULL,
    "poznamka" VARCHAR(100) DEFAULT NULL,
    "letovy_rezim_letu" VARCHAR(7) NOT NULL,
    CONSTRAINT "fk_let_letovy_rezim_letu"
        FOREIGN KEY ("letovy_rezim_letu")
        REFERENCES "letovy_rezim" ("id")
        ON DELETE SET NULL
);

CREATE TABLE "letadlo_leta_let" (
    "letadlo_seriove_cislo" INT NOT NULL,
    "let_id" INT NOT NULL,
    CONSTRAINT "pk_letadlo_leta_let"
        PRIMARY KEY ("letadlo_seriove_cislo", "let_id"),
    CONSTRAINT "fk_letadlo_leta_let_letadlo_seriove_cislo"
        FOREIGN KEY ("letadlo_seriove_cislo")
        REFERENCES "letadlo" ("seriove_cislo")
        ON DELETE SET NULL,
    CONSTRAINT "fk_letadlo_leta_let_let_id"
        FOREIGN KEY ("let_id")
        REFERENCES "let" ("id")
        ON DELETE SET NULL
);

CREATE TABLE "datum" (
    "datum" DATE NOT NULL PRIMARY KEY
);

CREATE TABLE "letovy_rezim_aktivni_v_datum" (
    "letovy_rezim_id" VARCHAR(7) NOT NULL,
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
        -- CHECK ( "celkova_cena" >= 0 ),
    "cas_expirace" TIMESTAMP NOT NULL,
        -- CHECK ( "cas_expirace" > CURRENT_TIMESTAMP ),
    "stav_uhrady" NUMBER(1) NOT NULL,
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
