/** 
VRAAG 1 
a. Voer in de  Patienten database de volgende structurele wijzigingen door:
In de tabel PATIENTOPNAMES moet een attribuut TOTAAL_BEDRAG toegevoegd 
(number(10,2)) worden, dat voor een patiënt het totaal bedrag van zijn 
behandelingen bijhoudt.
In de tabel VOORSCHRIFTEN moet het voorschriftnr ingevoerd worden via een 
sequence. De sequence moet nog aangemaakt worden: SEQ_VOORSCHRIFTNR met 
startwaarde 755445673 en ophoogwaarde 1.
b. Voer na de structurele wijzigingen de nodige updates uit zodat het 
hierboven  toegevoegde attribuut  up-to-date informatie bevat.
**/
ALTER TABLE patientopnames ADD TOTAAL_BEDRAG NUMBER(10,2);

CREATE SEQUENCE seq_voorschriften START WITH 755445673;

UPDATE patientopnames p 
SET TOTAAL_BEDRAG  = (select sum(prijs_beh) from behandelingen where opnamenr = p.opnamenr); 
COMMIT;

/**
VRAAG 2 
Schrijf een  procedure VOEG_PATIENTOPNAME_TOE die voor een bestaande patiënt 
een opname toevoegt.
Ook het bednummer moet ingegeven worden.  
Voor dit bednummer moet gecontroleerd worden of het beschikbaar is
(beschikbaarheid=J).  Als het bed niet beschikbaar is,  moet er een melding 
op het scherm komen en mag de insert niet doorgevoerd worden. 
Maak de wijziging definitief.
**/ 

CREATE OR REPLACE PROCEDURE voeg_patient_toe 
    (p_patientnr IN VARCHAR2
    ,p_sofi_nr IN VARCHAR2
    ,p_voornaam IN VARCHAR2
    ,p_achternaam IN VARCHAR2
    )
AS
BEGIN 
    INSERT INTO patienten(patientnr, sofi_nr, voornaam, achternaam)
    VALUES(p_patientnr, p_sofi_nr, p_voornaam,p_achternaam);
    COMMIT;
END voeg_patient_toe;

exec voeg_patient_toe ('99999','123321456','jan','Janssens');
select * from patienten where patientnr = '99999';

/* VRAAG  3
Schrijf een  procedure VOEG_PATIENTOPNAME_TOE die voor een bestaande patiënt 
een opname toevoegt.
Ook het bednummer moet ingegeven worden.  
Voor dit bednummer moet gecontroleerd worden of het beschikbaar is 
(beschikbaarheid=J).  Als het bed niet beschikbaar is,  moet er een melding 
op het scherm komen en mag de insert niet doorgevoerd worden. 
Maak de wijziging definitief.
*/

CREATE OR REPLACE PROCEDURE voeg_patientopname_toe 
(
    p_opname_nr IN PATIENTOPNAMES.OPNAMENR%TYPE,
    p_patientnr IN PATIENTEN.PATIENTNR%TYPE,
    p_uur IN PATIENTOPNAMES.UUR%TYPE,
    p_datum IN DATE :=sysdate,
    p_bednr IN PATIENTOPNAMES.BEDNR%TYPE 
)
IS
    v_beschikbaar bedden.beschikbaarheid%type; 
BEGIN 
    SELECT beschikbaarheid INTO v_beschikbaar from  bedden where bednr = p_bednr;
    IF v_beschikbaar = 'J'
        THEN 
            INSERT INTO PATIENTOPNAMES (opnamenr, patientnr, datum, uur,bednr)
            VALUES (p_opname_nr,p_patientnr,p_datum,p_uur,p_bednr);
            COMMIT;
        ELSE 
            DBMS_OUTPUT.PUT_LINE('BED met nummer' || p_bednr || 'is al bezet');
    END IF;
END voeg_patientopname_toe;
/
exec voeg_patientopname_toe(P_OPNAME_NR=>70,P_PATIENTNR=>'99999',P_UUR=>1200,P_BEDNR=>3);
exec voeg_patientopname_toe(P_OPNAME_NR=>71,P_PATIENTNR=>'100001',P_UUR=>1200,P_BEDNR=>4);

/* VRAAG 4 
Schrijf een procedure VOEG_BEHANDELING_TOE  die voor een patiënt een 
behandeling toevoegt aan de database.  
Behandelingsnummer, datum, opnamenr, persnr, verrichtingsnr en prijs_beh moeten
ingegeven worden. Denk aan het up-to-date houden van afgeleide kolommen! 
Vergeet de COMMIT niet.
*/
CREATE OR REPLACE PROCEDURE voeg_behandeling_toe 
(
    p_behnr IN BEHANDELINGEN.BEHNR%TYPE,
    p_datum IN BEHANDELINGEN.DATUM%TYPE :=sysdate, 
    p_opnamenr IN BEHANDELINGEN.OPNAMENR%TYPE, 
    p_persnr IN BEHANDELINGEN.PERSNR%TYPE, 
    p_verrichtingnr IN BEHANDELINGEN.VERRICHTINGNR%TYPE, 
    p_prijs_beh IN BEHANDELINGEN.PRIJS_BEH%TYPE
)
IS 
BEGIN 
    INSERT INTO BEHANDELINGEN (behnr, datum, opnamenr, persnr, verrichtingnr, prijs_beh)
    VALUES(p_behnr,p_datum,p_opnamenr,p_persnr,p_verrichtingnr,p_prijs_beh); 
    
    UPDATE patientopnames SET totaal_bedrag = NVL(totaal_bedrag,0) + p_prijs_beh;
    COMMIT;
END voeg_behandeling_toe;

/* VRAAG 5
Schrijf een procedure WIJZIG_BED_PATIENT die voor een patiënt een bedwissel regelt.  
De procedure heeft als parameters het opnamenr en het nieuwe bednummer. 
Denk bij het uitwerken van de procedure aan de beschikbaar van bedden en 
zorg ervoor dat alle nodige attributen aangepast worden! 
Maak de wijziging definitief binnen je procedure.
*/
CREATE OR REPLACE PROCEDURE wijzig_bed_patient 
(
    p_opnamenr IN PATIENTOPNAMES.OPNAMENR%TYPE,
    p_nieuw_bednr IN PATIENTOPNAMES.BEDNR%TYPE
)
IS
    v_beschikbaarheid PATIENTOPNAMES.BEDNR%TYPE;
BEGIN 
    SELECT beschikbaarheid INTO v_beschikbaarheid FROM BEDDEN where bednr= p_nieuw_bednr; 
    IF v_beschikbaarheid = 'J' 
        THEN
            UPDATE BEDDEN SET beschikbaarheid = 'N' where bednr = p_nieuw_bednr; 
            UPDATE BEDDEN SET beschikbaarheid = 'J' where bednr = (select bednr from PATIENTOPNAMES where opnamenr=p_opnamenr);
            UPDATE PATIENTOPNAMES SET bednr = p_nieuw_bednr where opnamenr = p_opnamenr; 
            commit;
        ELSE 
            DBMS_OUTPUT.PUT_LINE('BED met nummer' || p_nieuw_bednr || 'is al bezet');
    END IF;
END  wijzig_bed_patient ;
        
/* VRAAG 6
Schrijf een procedure VOEG_VOORSCHRIFT_TOE dat een voorschrift toevoegt aan de 
database.  Het voorschriftnr wordt via de sequence seq_voorschriftnr ingevuld 
Commit op het einde.
*/
CREATE OR REPLACE PROCEDURE voeg_voorschrift_toe 
(
    p_datum VOORSCHRIFTEN.DATUM%TYPE, 
    p_medcode VOORSCHRIFTEN.MEDCODE%TYPE,
    p_opnamenr VOORSCHRIFTEN.OPNAMENR%TYPE,
    p_persnr VOORSCHRIFTEN.PERSNR%TYPE,
    p_dos_voorgeschr VOORSCHRIFTEN.DOS_VOORSCHR%TYPE,
    p_voorschr_dos VOORSCHRIFTEN.VOORGESCHR_DOS%TYPE

)
IS
BEGIN
    INSERT INTO voorschriften (nr, datum, medcode,opnamenr,persnr,dos_voorschr,voorgeschr_dos)
    VALUES (SEQ_VOORSCHRIFTEN.NEXTVAL,p_datum, p_medcode, p_opnamenr, p_persnr, p_dos_voorgeschr, p_voorschr_dos); 
    commit;
END voeg_voorschrift_toe; 

 /* VRAAG 7
Schrijf een functie AANTAL_BEHANDELINGEN die bij het ingeven van een persnr 
het aantal behandelingen  dat hij/zij begeleidde berekent.
*/   

CREATE OR REPLACE FUNCTION aantal_behandelingen
( 
  p_persnr IN BEHANDELINGEN.PERSNR%TYPE
)
RETURN NUMBER
IS
 v_aantal NUMBER;
BEGIN 
 SELECT count(*) INTO v_aantal from behandelingen where persnr = p_persnr; 
 RETURN (v_aantal);
END aantal_behandelingen; 
    
/* VRAAG 8
Schrijf een procedure SALARISVERHOGING met parameter persnr, die aan 
administratieve medewerkers een loonsverhoging van 2,5% geeft.  
Voor een personeelslid met ziekenhuistitel  ‘vpk1’ moet eerst berekend worden 
hoeveel behandelingen hij/zij begeleidde.   
Gebruik daarbij de functie die je in de voorgaande vraag aanmaakte.   
Ligt dat aantal hoger dan 10 dan krijgt dat personeelslid 
een loonsverhoging van 5%. Commit.
*/   
CREATE OR REPLACE PROCEDURE salarisverhoging
(
    p_persnr IN PERSONEEL.PERSNR%TYPE 
) 
IS 
    v_titel PERSONEEL.ZIEKENHUISTITEL%TYPE;
    v_salarisverhoging NUMBER(5,3) := 1;
BEGIN 
    SELECT upper(ziekenhuistitel) 
    INTO v_titel 
    FROM personeel 
    WHERE persnr = p_persnr; 
    IF v_titel = 'VPK1' 
        THEN 
            IF aantal_behandelingen(p_persnr) > 10
            THEN
            v_salarisverhoging := 1.05;
            END IF;
    ELSE IF v_titel LIKE '%ADM%MDW%'
        THEN v_salarisverhoging := 1.025;
    END IF;
    
    UPDATE PERSONEEL SET SALARIS = SALARIS * v_salarisverhoging where persnr = p_persnr; 
    COMMIT; 
END salarisverhoging;

select * from personeel where persnr = 66532;
SALARISVERHOGING(P_PERSNR=>66532);

/* VRAAG 9
Schrijf een functie BESTE_VOORSCHRIJVER om de naam van de arts  op te halen 
die het meest aantal voorschriften uitschreef; 
*/   
CREATE OR REPLACE FUNCTION beste_voorschrijver 
RETURN VARCHAR2
IS 
    v_persnr voorschriften.persnr%TYPE;
    v_naam VARCHAR2(150)
BEGIN
SELECT persnr INTO v_persnr FROM 
    (select persnr, count(*) from voorschriften group by persnr)