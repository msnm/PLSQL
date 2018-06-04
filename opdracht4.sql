  -- Praktijkopgave 4 
  /* VRAAG 1:
  Vervolledig de PL/SQL procedure VOEG_PATIENT_TOE (uit project 1) die een 
  nieuwe patiënt toevoegt aan de database waarbij alle mogelijke fouten op 
  constraints worden opgevangen door exception-behandeling. 
-	patientnummer moet uniek zijn;
-	de familienaam moet ingevuld zijn en in uppercase staan; 
(is geen check-constraint in de tabel patienten!!)
-	de voornaam moet ingevuld zijn;
-	het sofi-nummer moet ingevuld zijn en uniek zijn;

  */
  
CREATE OR REPLACE PROCEDURE voeg_patient_toe
(   
     p_patientnr IN VARCHAR2
    ,p_sofi_nr IN VARCHAR2
    ,p_voornaam IN VARCHAR2
    ,p_achternaam IN VARCHAR2
)
IS
    e_not_null EXCEPTION; 
    PRAGMA EXCEPTION_INIT(e_not_null,-1400); -- User defined + ora 
    e_upper_exception EXCEPTION; -- User defined
BEGIN 
    IF UPPER(p_achternaam) != p_achternaam
        THEN RAISE e_upper_exception;
    END IF;
    INSERT INTO patienten(patientnr, sofi_nr, voornaam, achternaam)
    VALUES(p_patientnr, p_sofi_nr, p_voornaam,p_achternaam);
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX 
        THEN IF SQLERRM LIKE 'PK'
            THEN DBMS_OUTPUT.PUT_LINE('PK bestaat al voor ' || p_patientnr);
            ELSE DBMS_OUTPUT.PUT_LINE('SOFI_NR ' || p_sofi_nr ||' bestaat reeds!');
        END IF; 
    WHEN e_not_null
        THEN
        IF SQLERRM LIKE '%VOORNAAM%'
            THEN DBMS_OUTPUT.PUT_LINE('De familienaam ingevuld zijn');
        ELSE IF SQLERRM LIKE '%ACHTERNAAM%'
            THEN DBMS_OUTPUT.PUT_LINE('De achternaam moet ingevuld zijn');
        ELSE IF SQLERRM LIKE '%SOFI_NR%'
            THEN DBMS_OUTPUT.PUT_LINE('Sofi nr moet ingevuld wordenr');
        END IF;
        END IF;
        END IF;
    WHEN e_upper_exception
        THEN DBMS_OUTPUT.PUT_LINE('De familienaam moet in hoofdletters ingevuld zijn');
END voeg_patient_toe;
/
exec voeg_patient_toe(P_PATIENTNR=>-101,P_SOFI_NR=>null,P_VOORNAAM=>'michael',P_ACHTERNAAM=>'SCHOEN');
exec voeg_patient_toe(P_PATIENTNR=>-101,P_SOFI_NR=>123546,P_VOORNAAM=>null,P_ACHTERNAAM=>'SCHOEN');
exec voeg_patient_toe(P_PATIENTNR=>-101,P_SOFI_NR=>123546,P_VOORNAAM=>'michael',P_ACHTERNAAM=>null);

exec voeg_patient_toe(P_PATIENTNR=>-100,P_SOFI_NR=>15456,P_VOORNAAM=>'michael',P_ACHTERNAAM=>'SCHOENMAEKERS');
exec voeg_patient_toe(P_PATIENTNR=>-101,P_SOFI_NR=>123456,P_VOORNAAM=>'michael',P_ACHTERNAAM=>'SCHOENMAEKERS');
exec voeg_patient_toe(P_PATIENTNR=>-101,P_SOFI_NR=>12356,P_VOORNAAM=>'michael',P_ACHTERNAAM=>'Schoenmaekers');

/* VRAAG 
Vervolledig de PL/SQL procedure VOEG_PATIENTOPNAME_TOE (project 1) die een 
    nieuwe opname toevoegt aan de database  waarbij alle mogelijke fouten op 
    constraints worden opgevangen door exception-behandeling. 
-	Opnamenummer moet uniek zijn;
-	Het ingegeven uur moet liggen tussen 00 en 2400. (geen check constraint in de tabel patientopnames)
-	patientnr moet voorkomen als patient en moet ingevuld zijn;
-	bednr moet voorkomen als bed;
-	als het bed niet beschikbaar is, moet dit duidelijk gemeld worden. (via exception).
*/

create or replace PROCEDURE voeg_patientopname_toe 
(
    p_opname_nr IN PATIENTOPNAMES.OPNAMENR%TYPE,
    p_patientnr IN PATIENTEN.PATIENTNR%TYPE,
    p_uur IN PATIENTOPNAMES.UUR%TYPE,
    p_datum IN DATE :=sysdate,
    p_bednr IN PATIENTOPNAMES.BEDNR%TYPE 
)
IS
    v_beschikbaar bedden.beschikbaarheid%type; 
    e_niet_beschikbaar EXCEPTION;
    e_parrent_not_exist EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_parrent_not_exist,-2291);
    e_check EXCEPTION;
    e_not_null EXCEPTION; 
    PRAGMA EXCEPTION_INIT(e_not_null,-1400);
BEGIN 
    IF NOT SUBSTR(p_uur,1,2) BETWEEN 0 AND 23 OR NOT SUBSTR(p_uur,3,2)  BETWEEN 0 AND 59
        THEN RAISE e_check; 
    END IF;
    SELECT beschikbaarheid INTO v_beschikbaar from  bedden where bednr = p_bednr;
    IF v_beschikbaar = 'J'
        THEN 
            INSERT INTO PATIENTOPNAMES (opnamenr, patientnr, datum, uur,bednr)
            VALUES (p_opname_nr,p_patientnr,p_datum,p_uur,p_bednr);
            COMMIT;
        ELSE 
            RAISE e_niet_beschikbaar;
    END IF;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX 
        THEN DBMS_OUTPUT.PUT_LINE('Opnamenummer moet uniek zijn.');
    WHEN e_niet_beschikbaar
        THEN DBMS_OUTPUT.PUT_LINE('BED met nummer' || p_bednr || 'is al bezet');
    WHEN e_parrent_not_exist
        THEN IF SQLERRM LIKE '%BED%'
            THEN DBMS_OUTPUT.PUT_LINE('Bednr moet voorkomen als bed');
            ELSE IF SQLERRM LIKE '%PATIENT%'
            THEN DBMS_OUTPUT.PUT_LINE('Patientnr moet voorkomen als patient');
        END IF;
        END IF;
    WHEN e_check
        THEN DBMS_OUTPUT.PUT_LINE('Het opgegeven uur ligt niet tussen 00 en 2400');
END voeg_patientopname_toe;

/* VRAAG 3
Schrijf de procedure VERWIJDER_PATIENT met parameter patientnr. 
(b.v. bij het overlijden van de patiënt)
Heeft de patiënt geen patientenopnames, dan komt een gepaste melding.
Indien de patiënt wel patientopnames heeft, worden alle gegevens van die patiënt
gekopieerd naar de resp. archieftabellen en verwijderd in de oorspronkelijke
tabellen.
Aanmaak Archieftabellen:
*/ 
CREATE OR REPLACE PROCEDURE verwijder_patient (p_patientnr PATIENTEN.PATIENTNR%TYPE)
IS
    CURSOR cur_opname IS 
        SELECT * FROM patientopnames WHERE patientnr=p_patientnr;
    ex_not_found EXCEPTION;
BEGIN
    FOR r_opname IN cur_opname 
    LOOP
        IF cur_opname%NOTFOUND
            THEN RAISE ex_not_found;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Found'|| r_opname.patientnr);
        END IF;
    END LOOP;
EXCEPTION
    WHEN ex_not_found
        THEN DBMS_OUTPUT.PUT_LINE('Did not found '|| p_patientnr);
END verwijder_patient;
/
exec verwijder_patient(P_PATIENTNR=>-200);