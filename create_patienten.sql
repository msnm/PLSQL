BEGIN
EXECUTE IMMEDIATE 'DROP TABLE voorschriften CASCADE CONSTRAINTS';
EXECUTE IMMEDIATE 'DROP TABLE medicijnen CASCADE CONSTRAINTS';
EXECUTE IMMEDIATE 'DROP TABLE pers_specialisaties CASCADE CONSTRAINTS';
EXECUTE IMMEDIATE 'DROP TABLE specialisaties CASCADE CONSTRAINTS';
EXECUTE IMMEDIATE 'DROP TABLE behandelingen';
EXECUTE IMMEDIATE 'DROP TABLE verrichtingen';
EXECUTE IMMEDIATE 'DROP TABLE verrichting_categorieen';
EXECUTE IMMEDIATE 'DROP TABLE afdelingen cascade constraints';
EXECUTE IMMEDIATE 'DROP TABLE personeel cascade constraints';
EXECUTE IMMEDIATE 'DROP TABLE patientopnames cascade constraints';
EXECUTE IMMEDIATE 'DROP TABLE patientfiches cascade constraints';
EXECUTE IMMEDIATE 'DROP TABLE patienten cascade constraints';
EXECUTE IMMEDIATE 'DROP TABLE bedden cascade constraints';
EXECUTE IMMEDIATE 'DROP TABLE bedtypes cascade constraints';
EXECUTE IMMEDIATE 'DROP TABLE  kamers cascade constraints';
EXECUTE IMMEDIATE 'DROP TABLE behandelingen CASCADE CONSTRAINTS';
EXECUTE IMMEDIATE 'DROP SEQUENCE seq_opname';
EXCEPTION WHEN OTHERS
THEN
NULL;
END;
/
--REM Creeer de tabellen.
--REM Tabel kamers
CREATE TABLE kamers (
    kamernr               		 	VARCHAR2(6) 
        CONSTRAINT pk_kamer PRIMARY KEY, 
    omschr      				VARCHAR2(25));
    
REM Tabel bedtypes
CREATE TABLE bedtypes (
    bedtypenr             			VARCHAR2(2)  
        CONSTRAINT pk_bed_type PRIMARY KEY, 
    omschr   					VARCHAR2(50));

REM Tabel bedden
CREATE TABLE bedden (
    bednr                  			NUMBER(4) 
        CONSTRAINT pk_bed PRIMARY KEY, 
    kamernr            				VARCHAR2(6) 
        CONSTRAINT fk_bed_kamer REFERENCES kamers(kamernr),
    bedtypenr             			VARCHAR2(2)
        CONSTRAINT nn_bed_typenr NOT NULL
        CONSTRAINT fk_bed_bedtype REFERENCES bedtypes(bedtypenr),
    beschikbaarheid     			VARCHAR2(1)
	CONSTRAINT c_beschikbaarheid CHECK(upper(beschikbaarheid) in ('J','N')),
    lst_bijwerkdat          			DATE );

REM Tabel patienten
CREATE TABLE patienten (
    patientnr              			VARCHAR2(6)
        CONSTRAINT pk_patient PRIMARY KEY, 
    sofi_nr        				VARCHAR2(9) 
        CONSTRAINT nn_patient_sofi_nr NOT NULL
	CONSTRAINT u_Pat_sofi_nr UNIQUE, 
    achternaam      				VARCHAR2(50) 
        CONSTRAINT nn_patient_achternaam NOT NULL,
    voornaam        VARCHAR2(50)
        CONSTRAINT nn_patient_voornaam NOT NULL,
    tussenvoegsel   				VARCHAR2(50), 
    adres           				VARCHAR2(50),
    plaats         				VARCHAR2(50),
    provincie      				VARCHAR2(2),
    postcode        				VARCHAR2(7),
    gebdatum   					DATE,
    telnr         				VARCHAR2(10),
    lst_bijwerkdat          			DATE );
CREATE TABLE patientopnames(
    opnamenr					NUMBER(5)
	CONSTRAINT pk_patientopname PRIMARY KEY,
    datum        				DATE,
    uur         				NUMBER(4),
    patientnr              			VARCHAR2(6)
        CONSTRAINT fk_patientopname_patient REFERENCES patienten(patientnr),
    bednr          				NUMBER(4) 
        CONSTRAINT fk_patientopname_bed REFERENCES bedden(bednr));
    
REM Tabel patientfiches
CREATE TABLE patientfiches (
    opnamenr           				NUMBER(5), 
    datum        				DATE,
    uur         				NUMBER(4),
    commentaar   				VARCHAR2(4000),
    CONSTRAINT fk_patientfiche_patientopname FOREIGN KEY (opnamenr) REFERENCES patientopnames,
    CONSTRAINT pk_patientfiche PRIMARY KEY (opnamenr, datum ,uur) );

REM Tabel afdelingen
CREATE TABLE afdelingen (
    afdnr             				VARCHAR2(5) 
        CONSTRAINT pk_afdeling PRIMARY KEY, 
    naam           				VARCHAR2(50) 
        CONSTRAINT nn_afdeling_naam NOT NULL,
    kantoorlocatie 				VARCHAR2(25) 
        CONSTRAINT nn_afdeling_kantoorlocatie NOT NULL,
    telnr         				VARCHAR2(10));
    
REM Tabel personeel
CREATE TABLE personeel (
    persnr                 			VARCHAR2(5) 
        CONSTRAINT pk_personeel PRIMARY KEY, 
    sofi_nr            				VARCHAR2(9) 
        CONSTRAINT nn_pers_sofi_nr NOT NULL
	CONSTRAINT u_Pers_sofi_nr UNIQUE, 
    achternaam         				VARCHAR2(50) 
        CONSTRAINT nn_pers_achternaam NOT NULL,
    voornaam           				VARCHAR2(50) 
        CONSTRAINT nn_pers_voornaam NOT NULL,
    tussenvoegsel      				VARCHAR2(50), 
    afd_toegewezen     				VARCHAR2(5) 
        CONSTRAINT fk_personeel_afdeling REFERENCES afdelingen(afdnr),
    kantoorlocatie   				VARCHAR2(10),
    datum_in_dienst    				DATE DEFAULT NULL,
    ziekenhuistitel   				VARCHAR2(50) 
        CONSTRAINT nn_pers_ziekenhuistitel NOT NULL,
    telwerk           				VARCHAR2(10),
    teldoorkies       				VARCHAR2(4),
    regnr             				VARCHAR2(20),
    salaris            				NUMBER,
    tarief            				NUMBER(5,2));
    
CREATE TABLE verrichting_categorieen (
    cat_nr   VARCHAR2(3) 
        CONSTRAINT pk_verrichting_cat PRIMARY KEY, 
    cat_omschrijving VARCHAR2(50) 
        CONSTRAINT nn_verrichting_cat_oms NOT NULL);

REM Tabel verrichtingen
CREATE TABLE verrichtingen (
    nr          VARCHAR2(5) 
        CONSTRAINT pk_verrichtingen PRIMARY KEY, 
    omschrijving VARCHAR2(50) 
        CONSTRAINT nn_verrichting_omschrijving NOT NULL,
    eenhpr_verr  NUMBER(9,2) 
        CONSTRAINT ck_verrichting_rek_totaal CHECK (eenhpr_verr >= 0),
    opmerking   VARCHAR2(2000),
    cat_nr      VARCHAR2(3) 
        CONSTRAINT fk_verrichting_cat_nr REFERENCES verrichting_categorieen(cat_nr));
REM Tabel behandelingen
CREATE TABLE behandelingen (
    behnr          				NUMBER(9),
    datum       				DATE,
    opnamenr  					NUMBER(5) 
        CONSTRAINT nn_behandeling_patientnr NOT NULL,
    persnr     					VARCHAR2(5) 
        CONSTRAINT nn_behandeling_persnr NOT NULL,
    verrichtingnr 				VARCHAR2(5) 
        CONSTRAINT nn_behandeling_verrichting_nr NOT NULL,
    prijs_beh 				NUMBER(9,2) 
        CONSTRAINT ck_beh_huidige_rek_totaal CHECK (prijs_beh >= 0),
   opmerking   					VARCHAR2(2000),
        CONSTRAINT fk_behandeling_opnamepatient FOREIGN KEY (opnamenr) REFERENCES patientopnames,
    CONSTRAINT fk_behandeling_personeel FOREIGN KEY (persnr) REFERENCES personeel,
    CONSTRAINT fk_behandeling_verrichtingen FOREIGN KEY (verrichtingnr) REFERENCES verrichtingen,
    CONSTRAINT pk_behandeling PRIMARY KEY (behnr, datum) );
REM Tabel specialisaties
CREATE TABLE specialisaties (
    code              VARCHAR2(4) 
        CONSTRAINT pk_specialisatie PRIMARY KEY, 
    titel           VARCHAR2(50) 
        CONSTRAINT nntitel NOT NULL,  
    hoe_behaald     VARCHAR2(100));

REM Tabel pers_specialisaties
CREATE TABLE pers_specialisaties (
    persnr              VARCHAR2(5),
    code           VARCHAR2(4),
    datum_behaald        DATE DEFAULT SYSDATE,
    CONSTRAINT fk_pers_spec_pers FOREIGN KEY (persnr) REFERENCES personeel,
    CONSTRAINT fk_pers_spec_spec FOREIGN KEY (code) REFERENCES specialisaties,
    CONSTRAINT pk_pers_spec PRIMARY KEY (persnr, code) );
REM Tabel medicijnen
CREATE TABLE medicijnen (
    medcode             VARCHAR2(7) 
        CONSTRAINT pk_medicijn PRIMARY KEY, 
    wetnaam  VARCHAR2(50) 
        CONSTRAINT nn__wetnaam NOT NULL,
    handelsnaam    VARCHAR2(50) 
        CONSTRAINT nn_handelsnaam NOT NULL,
    normale_dos    VARCHAR2(300) 
        CONSTRAINT nn_medicijn_dosering NOT NULL,
   opmerking      VARCHAR2(500),
    voorraad_hoev  NUMBER(12) 
        CONSTRAINT ck_voorraad_hoev 
        CHECK (voorraad_hoev >= 0),
    eenheid        VARCHAR2(20));

REM Tabel voorschriften
CREATE TABLE voorschriften (
    nr               NUMBER(9) 
        CONSTRAINT pk_voorschrift PRIMARY KEY, 
    datum            DATE,
    medcode      VARCHAR2(7) 
        CONSTRAINT nn_medcode NOT NULL,
    opnamenr       NUMBER(5) 
        CONSTRAINT nn_patientnr NOT NULL, 
    persnr          VARCHAR2(5) 
        CONSTRAINT nn_persnr NOT NULL,
    voorgeschr_dos   VARCHAR2(50)  
        CONSTRAINT nn_voorgeschr_dos NOT NULL,
    dos_voorschr     VARCHAR2(500),
    CONSTRAINT fk_voorschrift_medicijn FOREIGN KEY (medcode) REFERENCES medicijnen,
    CONSTRAINT fk_voorschrift_patientopname FOREIGN KEY (opnamenr) REFERENCES patientopnames,
    CONSTRAINT fk_voorschrift_personeel FOREIGN KEY (persnr) REFERENCES personeel );



