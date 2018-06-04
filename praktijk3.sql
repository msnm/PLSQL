/* Vraag 1
Herschrijf de procedure VOORSCHRIJFGEDRAG (vraag 1 Project 2) en maak nu voor 
je oplossing gebruik van een CURSOR. 
*/
create or replace PROCEDURE voorschrijfgedrag_cur
    (p_medcode IN MEDICIJNEN.MEDCODE%TYPE) 
IS 
    CURSOR cur_vg IS
        SELECT p.persnr, p.achternaam, count(*) aantal
        FROM voorschriften v JOIN personeel p ON (v.persnr = p.persnr)
        WHERE v.medcode = p_medcode 
        GROUP BY p.persnr, p.achternaam
        ORDER BY 3 desc;
BEGIN 
        DBMS_OUTPUT.PUT_LINE('Voorschrijfgedrag ' || p_medcode);
        FOR r_vg IN cur_vg 
        LOOP
           DBMS_OUTPUT.PUT_LINE(
                            r_vg.persnr || ' ' ||
                            r_vg.achternaam ||' ' || 
                            r_vg.aantal
                            );
    END LOOP;
END voorschrijfgedrag_cur;
/
exec VOORSCHRIJFGEDRAG_CUR(P_MEDCODE=>9999003);
/

/*VRAAG 2
Herschrijf de procedure DUURSTE_PATIENTEN (vraag 2 Project 2) en maak nu 
voor je oplossing gebruik van een CURSOR.
*/
CREATE OR REPLACE PROCEDURE duurste_patienten_cur 
IS 
    CURSOR cur_duurste 
    IS
        SELECT po.patientnr, p.achternaam, sum(po.TOTAAL_BEDRAG) totaal_bedrag
        FROM patientopnames po
        JOIN patienten p ON (po.patientnr = p.patientnr)
        WHERE po.totaal_bedrag IS NOT NULL
        GROUP BY po.patientnr,p.achternaam
        ORDER BY 3 DESC; 
BEGIN 
    DBMS_OUTPUT.PUT_LINE(
    'patientnr      patientnaam     total bedrag');
     DBMS_OUTPUT.PUT_LINE(
    '===============================================');
    FOR r_duurste IN cur_duurste
    LOOP 
         DBMS_OUTPUT.PUT_LINE(
           RPAD( r_duurste.patientnr,15, ' ') || ' ' ||
           RPAD(r_duurste.achternaam,13, ' ') || ' ' ||    
           r_duurste.totaal_bedrag
            );
        IF (cur_duurste%ROWCOUNT=10)
        THEN
            EXIT;
        END IF;
    END LOOP; 
END duurste_patienten_cur;
/
exec duurste_patienten_cur();

/* VRAAG 3
Schrijf een procedure LOON_NAAR_BEHANDELEN die personeelsleden die minstens n 
(input parameter) behandelingen verzorgden, een salarisverhoging van 5% geeft. 
Zorg ervoor dat voor elke verwerkte rij persnr en nieuw loon getoond worden op 
het scherm (tip: gebruik RETURNING –optie).
*/
CREATE OR REPLACE PROCEDURE loon_naar_behandelen (p_aantal IN NUMBER)
IS 
    CURSOR cur_aantal_beh
    IS 
        select b.persnr FROM behandelingen b GROUP BY b.persnr HAVING count(*) > p_aantal;
    TYPE type_rec_pers IS RECORD 
    (
        persnr personeel.persnr%type,
        salaris personeel.salaris%type
    );
    r_pers type_rec_pers; 
BEGIN
    FOR r_aantal_beh IN cur_aantal_beh
    LOOP
        UPDATE personeel SET salaris = salaris * 1.05
        WHERE persnr = r_aantal_beh.persnr
        RETURNING persnr, salaris INTO r_pers; 
        DBMS_OUTPUT.PUT_LINE(r_pers.persnr ||' ' || r_pers.salaris);
    END LOOP;
    COMMIT;
END loon_naar_behandelen; 
/
exec loon_naar_behandelen(10);

/* VRAAG 4
Herschrijf de procedure OVERZICHT_PERSONEELSLEDEN_AFD  (vraag 4 Project 2) en 
maak voor je oplossing gebruik van multiple cursors;
*/
CREATE OR REPLACE PROCEDURE personeelsleden_afd_cur 
IS 
    CURSOR cur_afd 
    IS 
    SELECT afdnr, naam FROM afdelingen order by naam;
    
    CURSOR cur_persn (p_afdnr PERSONEEL.AFD_TOEGEWEZEN%TYPE) 
    IS
    SELECT achternaam, salaris from personeel where afd_toegewezen = p_afdnr; 
    
BEGIN
    FOR r_afd IN cur_afd 
    LOOP
        DBMS_OUTPUT.PUT_LINE(r_afd.afdnr || ' ' || r_afd.naam);
        DBMS_OUTPUT.PUT_LINE('==================================================');
        
        FOR r_persn IN cur_persn(r_afd.afdnr) 
        LOOP
            DBMS_OUTPUT.PUT_LINE(RPAD(r_persn.achternaam,20, ' ') ||' '|| RPAD(r_persn.salaris,20));
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(' ');
    END LOOP;
END personeelsleden_afd_cur;
/
exec personeelsleden_afd_cur;

/* VRAAG 5
Schrijf een procedure OVERZICHT_SPECIALISATIES die een overzicht  per 
personeelslid een overzicht geeft van zijn/haar specialisaties.
Heeft een personeelslid geen specialisaties, dan moet onder zijn/haar naam 
de tekst ‘geen specialisaties ‘ komen.
*/
CREATE OR REPLACE PROCEDURE overzicht_specialisaties
IS
    CURSOR cur_pers IS SELECT persnr, voornaam, achternaam from personeel; 
    CURSOR cur_spec (p_persnr personeel.persnr%type) IS 
        SELECT s.code, s.titel, ps.datum_behaald 
        FROM specialisaties s 
        JOIN pers_specialisaties ps ON ps.code = s.code
        WHERE ps.persnr = p_persnr;
BEGIN
    FOR r_pers IN cur_pers
    LOOP
        DBMS_OUTPUT.PUT_LINE(r_pers.voornaam || ' ' || r_pers.achternaam);
        DBMS_OUTPUT.PUT_LINE(RPAD('-',LENGTH(r_pers.voornaam || ' ' || r_pers.achternaam),'-'));
        FOR r_spec IN cur_spec(r_pers.persnr)
        LOOP
           IF cur_spec%NOTFOUND
           THEN DBMS_OUTPUT.PUT_LINE('geen specialisaties');
           ELSE 
                DBMS_OUTPUT.PUT_LINE(r_spec.code || ' ' || r_spec.titel || ' ' || r_spec.datum_behaald);
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(' ');
    END LOOP;
END overzicht_specialisaties; 
/
exec overzicht_specialisaties;