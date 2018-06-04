-- Oefening vier 
-- Schrijf een PL/SQL programma dat op het scherm weergeeft 
-- op welke dag (dagnaam geven) Valentijn de komende 5 jaren valt
-- (dit jaar inbegrepen).
-- Gebruik voor uw oplossing de functies
-- to_char(datumveld,’DY ‘) en add_months(datumveld, integer)
CREATE OR REPLACE PROCEDURE valentijn
AS
tel pls_integer :=0;
BEGIN
FOR i IN 0..4
LOOP
DBMS_OUTPUT.PUT_LINE(TO_CHAR(ADD_MONTHS('09-feb-2017',12*i),'DY'));
END LOOP;
END valentijn;


CREATE OR REPLACE PROCEDURE kerstdag
AS
tel pls_integer :=0;
BEGIN
WHILE tel<5
LOOP
DBMS_OUTPUT.PUT_LINE(TO_CHAR(ADD_MONTHS
('25-dec-2016',12*tel),'DY'));
tel:=tel+1;
END LOOP;
END kerstdag;


CREATE OR REPLACE PROCEDURE aanpassing_loon
AS
BEGIN
UPDATE medewerkers
SET maandsal=maandsal*1.1
WHERE mnr in 
     (SELECT mnr
      FROM medewerkers 
      JOIN schalen ON (maandsal BETWEEN ondergrens AND  bovengrens)
      WHERE  snr IN (4,5));
DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT||' maandsalarissen aangepast');
END;   
