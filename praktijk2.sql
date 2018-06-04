

/* Vraag 1
Men wil een zicht krijgen op het voorschrijfgedrag van dokters voor bepaalde 
medicatie.  Schrijf een procedure VOORSCHRIJFGEDRAG  die bij het ingeven van een
medicijncode een overzicht geeft van het aantal voorschriften dat een arts 
van dat medicijn voorschreef. Artsen die het meest voorschreven moeten bovenaan 
de lijst komen. Maak gebruik van een record- en arraytype. 
Toon persnr, achternaam en aantal.
*/
create or replace PROCEDURE voorschrijfgedrag 
    (p_medcode IN MEDICIJNEN.MEDCODE%TYPE) 
IS 
    TYPE type_rec_voorschrijfgedrag IS RECORD 
    (
        persnr VOORSCHRIFTEN.PERSNR%TYPE,
        achternaam PERSONEEL.ACHTERNAAM%TYPE,
        aantal NUMBER(3) 
     );
    TYPE type_tab_voorschrijfgedrag IS TABLE OF type_rec_voorschrijfgedrag INDEX BY PLS_INTEGER; 
    t_voorschrijfgedrag type_tab_voorschrijfgedrag; 
BEGIN 
    SELECT p.persnr, p.achternaam, count(*)
    BULK COLLECT INTO t_voorschrijfgedrag
    FROM voorschriften v JOIN personeel p ON (v.persnr = p.persnr)
    WHERE v.medcode = p_medcode 
    GROUP BY p.persnr, p.achternaam
    ORDER BY 3 desc;

    DBMS_OUTPUT.PUT_LINE('Voorschrijfgedrag ' || p_medcode);
    FOR i IN 1..t_voorschrijfgedrag.COUNT
    LOOP
        DBMS_OUTPUT.PUT_LINE(
                            t_voorschrijfgedrag(i).persnr || ' ' ||
                            t_voorschrijfgedrag(i).achternaam ||' ' || 
                            t_voorschrijfgedrag(i).aantal
                            );
    END LOOP;
END voorschrijfgedrag;
/
exec VOORSCHRIJFGEDRAG(P_MEDCODE=>9999017);
/

/* Vraag 2 
Schrijf een procedure DUURSTE PATIENTEN, die voor de 10 duurste  patiënten het 
totaalbedrag aan behandelingskosten weergeeft. 
(som van behandelingskosten alle opnames). 
Let op de layout van de output.
*/
CREATE OR REPLACE PROCEDURE duurste_patienten 
IS 
    TYPE type_rec_kp IS RECORD 
    (
        patientnr PATIENTEN.PATIENTNR%TYPE,
        patientnaam PATIENTEN.ACHTERNAAM%TYPE, 
        totaal_bedrag number(5)
    );
    TYPE type_tab_kp IS TABLE OF type_rec_kp INDEX BY PLS_INTEGER; 
    t_kp type_tab_kp; 
BEGIN 
    SELECT po.patientnr, p.achternaam, sum(po.TOTAAL_BEDRAG) BULK COLLECT INTO t_kp
    FROM patientopnames po
    JOIN patienten p ON (po.patientnr = p.patientnr)
    WHERE po.totaal_bedrag IS NOT NULL
    GROUP BY po.patientnr,p.achternaam
    ORDER BY 3 DESC; 
    
    DBMS_OUTPUT.PUT_LINE(
    'patientnr      patientnaam     total bedrag');
     DBMS_OUTPUT.PUT_LINE(
    '===============================================');
    
    FOR i IN 1..10
    LOOP 
         DBMS_OUTPUT.PUT_LINE(
           RPAD( t_kp(i).patientnr,15, ' ') || ' ' ||
           RPAD(t_kp(i).patientnaam,13, ' ') || ' ' ||    
           t_kp(i).totaal_bedrag
            );
    END LOOP; 
END duurste_patienten;
/
exec duurste_patienten();
/

/* VRAAG 3 
Om statistische redenen wil de ziekenhuisapotheek  weten hoeveel voorschriften 
er per afdeling werden uitgeschreven.  Geef afdelingnaam en aantal.
*/
CREATE OR REPLACE PROCEDURE voorschriften_per_afdeling
IS 
    TYPE type_rec_vpa IS RECORD 
    (
        afd AFDELINGEN.NAAM%TYPE,
        aantal NUMBER(3)
    );
    TYPE type_tab_vpa IS TABLE OF type_rec_vpa INDEX BY PLS_INTEGER;
    t_vpa type_tab_vpa; 
BEGIN
    SELECT a.naam, count(*) BULK COLLECT INTO t_vpa
    FROM afdelingen a 
    JOIN personeel p ON (a.afdnr = p.afd_toegewezen)
    JOIN voorschriften v ON (p.persnr = v.persnr) 
    GROUP BY a.NAAM
    ORDER BY 2 DESC;

    FOR i IN 1..t_vpa.COUNT 
    LOOP
        dbms_output.put_line(RPAD(t_vpa(i).afd,15,' ') || ' ' ||t_vpa(i).aantal);
    END LOOP;
END voorschriften_per_afdeling; 
/
exec voorschriften_per_afdeling();

/* VRAAG 4
Schrijf een procedure OVERZICHT_PERSONEELSLEDEN_AFD waarbij je de personeelsleden 
rangschikt per afdeling (afdelingen alfabetisch op naam van de afdeling) en 
binnen een afdeling volgens salaris van hoog naar laag.  
Definieer je eigen record- en arraytype!  
*/

CREATE OR REPLACE PROCEDURE overzicht_personeelsleden_afd 
IS 
    TYPE type_rec_opa IS RECORD 
    (
        afdnr AFDELINGEN.AFDNR%TYPE,
        afdnaam AFDELINGEN.NAAM%TYPE,
        achternaam PERSONEEL.ACHTERNAAM%TYPE,
        salaris PERSONEEL.SALARIS%TYPE
    );
    TYPE type_tab_opa IS TABLE OF type_rec_opa INDEX BY PLS_INTEGER;
    t_opa type_tab_opa;
    v_vorig AFDELINGEN.AFDNR%TYPE;
BEGIN
    SELECT a.afdnr, a.naam, p.achternaam, p.salaris BULK COLLECT INTO t_opa
    FROM personeel p JOIN afdelingen a ON p.AFD_TOEGEWEZEN = a.afdnr
    ORDER BY 2, 4 DESC, 3;
    
    v_vorig:='DUM'; 
    FOR i IN 1..t_opa.COUNT
    LOOP
        IF(v_vorig != t_opa(i).afdnr) 
            THEN 
                v_vorig := t_opa(i).afdnr;
                DBMS_OUTPUT.PUT_LINE(t_opa(i).afdnr || ' ' || t_opa(i).afdnaam);
                DBMS_OUTPUT.PUT_LINE('==================================================');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE(RPAD(t_opa(i).achternaam,20, ' ') ||' '|| RPAD(t_opa(i).salaris,20));
    END LOOP;
END overzicht_personeelsleden_afd;
/
exec overzicht_personeelsleden_afd;

/* VRAAG  5
De 2 personeelsleden met het meeste dienstjaren uit een willekeurig in te geven 
afdeling krijgen een salarisverhoging van 2,5% op voorwaarde dat ze minder 
dan 5 voorschriften uitschreven. Los deze opgave op een performante manier op:
procedure SALVERHOGING
*/

CREATE OR REPLACE PROCEDURE SALVERHOGING (p_afd AFDELINGEN.AFDNR%TYPE)
IS 
    TYPE t_tab_persnr IS TABLE OF PERSONEEL.PERSNR%TYPE INDEX BY PLS_INTEGER; 
    t_persnr t_tab_persnr;
BEGIN 
    SELECT persnr BULK COLLECT INTO t_persnr FROM personeel
    where afd_toegewezen = p_afd 
    and 5 < (select count(*) from voorschriften v where v.persnr = persnr)
    order by datum_in_dienst ASC;
    
    FORALL i IN INDICES OF t_persnr BETWEEN 1 AND 2
    UPDATE personeel set salaris = 1.025*salaris where persnr = t_persnr(i);
END SALVERHOGING;
/
ROLLBACK;
salverhoging('HEEL1');


