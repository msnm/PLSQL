REM =============================================================
REM SQL*Plus script vulcase.sql: vult de casustabellen (opnieuw)
REM Leerboek Oracle SQL, Lex de Haan
REM Derde editie, Academic Service 2004
REM =============================================================

alter session  set NLS_DATE_FORMAT='DD-MM-YYYY';

REM ================================================
REM Disable constraints (maakt vullen gemakkelijker)
REM ================================================

alter table medewerkers disable primary key cascade;
alter table medewerkers disable constraint M_CHEF_FK;
alter table medewerkers disable constraint M_AFD_FK;
alter table historie    disable constraint H_AFD_FK;

REM ==============================================
REM Tabel MEDEWERKERS (MNR,NAAM,VOORL,FUNCTIE,CHEF
REM                   ,GBDATUM,MAANDSAL,COMM,AFD)
REM ==============================================

truncate table medewerkers;

insert into medewerkers values(7369,'SMIT'       ,'N'  ,'TRAINER'   ,7902
                                   ,'17-12-1965' , 800 , NULL       ,20);
insert into medewerkers values(7499,'ALDERS'     ,'JAM','VERKOPER'  ,7698
                                   ,'20-02-1961' , 1600, 300        ,30);
insert into medewerkers values(7521,'DE WAARD'   ,'TF' ,'VERKOPER'  ,7698
                                   ,'22-02-1962' , 1250, 500        ,30);
insert into medewerkers values(7566,'JANSEN'     ,'JM' ,'MANAGER'   ,7839
                                   ,'02-04-1967' , 2975, NULL       ,20);
insert into medewerkers values(7654,'MARTENS'    ,'P'  ,'VERKOPER'  ,7698
                                   ,'28-09-1956' , 1250, 1400       ,30);
insert into medewerkers values(7698,'BLAAK'      ,'R'  ,'MANAGER'   ,7839
                                   ,'01-11-1963' , 2850, NULL       ,30);
insert into medewerkers values(7782,'CLERCKX'    ,'AB' ,'MANAGER'   ,7839
                                   ,'09-06-1965' , 2450, NULL       ,10);
insert into medewerkers values(7788,'SCHOTTEN'   ,'SCJ','TRAINER'   ,7566
                                   ,'26-11-1959' , 3000, NULL       ,20);
insert into medewerkers values(7839,'DE KONING'  ,'CC' ,'DIRECTEUR' ,NULL
                                   ,'17-11-1952' , 5000, NULL       ,10);
insert into medewerkers values(7844,'DEN DRAAIER','JJ' ,'VERKOPER'  ,7698
                                   ,'28-09-1968' , 1500, 0          ,30);
insert into medewerkers values(7876,'ADAMS'      ,'AA' ,'TRAINER'   ,7788
                                   ,'30-12-1966' , 1100, NULL       ,20);
insert into medewerkers values(7900,'JANSEN'     ,'R'  ,'BOEKHOUDER',7698
                                   ,'03-12-1969' , 800 , NULL       ,30);
insert into medewerkers values(7902,'SPIJKER'    ,'MG' ,'TRAINER'   ,7566
                                   ,'13-02-1959' , 3000, NULL       ,20);
insert into medewerkers values(7934,'MOLENAAR'   ,'TJA','BOEKHOUDER',7782
                                   ,'23-01-1962' , 1300, NULL       ,10);

alter table medewerkers enable primary key;

REM =========================================
REM Tabel AFDELINGEN (ANR,NAAM,LOCATIE,HOOFD)
REM =========================================

truncate table afdelingen;

insert into afdelingen values (10,'HOOFDKANTOOR'   ,'LEIDEN'   ,7782);
insert into afdelingen values (20,'OPLEIDINGEN'    ,'DE MEERN' ,7566);
insert into afdelingen values (30,'VERKOOP'        ,'UTRECHT'  ,7698);
insert into afdelingen values (40,'PERSONEELSZAKEN','GRONINGEN',7839);

REM =================================================
REM Tabel SCHALEN (SNR,ONDERGRENS,BOVENGRENS,TOELAGE)
REM =================================================

truncate table schalen;

insert into schalen values (1,   700,1200,    0);
insert into schalen values (2,  1201,1400,   50);
insert into schalen values (3,  1401,2000,  100);
insert into schalen values (4,  2001,3000,  200);
insert into schalen values (5,  3001,9999,  500);

REM ===============================================
REM Tabel CURSUSSEN (CODE,OMSCHRIJVING,TYPE,LENGTE)
REM Vier code/omschrijvingen aangepast in 3e editie
REM gepropageerd naar UITVOERINGEN / INSCHRIJVINGEN
REM ===============================================

alter table cursussen disable primary key cascade;
truncate table cursussen;

insert into cursussen values
      ('S02','Introductiecursus SQL',           'ALG',4);
insert into cursussen values
      ('OAG','Oracle voor applicatiegebruikers','ALG',1);
insert into cursussen values
      ('JAV','Java voor Oracle ontwikkelaars',  'BLD',4);
insert into cursussen values
      ('PLS','Introductie PL/SQL',              'BLD',1);
insert into cursussen values
      ('XML','XML voor Oracle ontwikkelaars',   'BLD',2);
insert into cursussen values
      ('ERM','Datamodellering met ERM',         'DSG',3);
insert into cursussen values
      ('PMT','Procesmodelleringstechnieken',    'DSG',1);
insert into cursussen values
      ('RSO','Relationeel systeemontwerp',      'DSG',2);
insert into cursussen values
      ('PRO','Prototyping',                     'DSG',5);
insert into cursussen values
      ('GEN','Systeemgeneratie',                'DSG',4);

alter table cursussen enable primary key;

REM =====================================================
REM Tabel UITVOERINGEN (CURSUS,BEGINDATUM,DOCENT,LOCATIE)
REM Jaartallen verhoogd met 4 jaar en begindata veranderd
REM =====================================================

alter table uitvoeringen disable primary key cascade;
truncate table uitvoeringen;

insert into uitvoeringen   values ('S02','12-04-1999',7902,'DE MEERN'  );
insert into uitvoeringen   values ('OAG','10-08-1999',7566,'UTRECHT'   );
insert into uitvoeringen   values ('S02','04-10-1999',7369,'MAASTRICHT');
insert into uitvoeringen   values ('S02','13-12-1999',7369,'DE MEERN'  );
insert into uitvoeringen   values ('JAV','13-12-1999',7566,'MAASTRICHT');
insert into uitvoeringen   values ('XML','03-02-2000',7369,'DE MEERN'  );
insert into uitvoeringen   values ('JAV','01-02-2000',7876,'DE MEERN'  );
insert into uitvoeringen   values ('PLS','11-09-2000',7788,'DE MEERN'  );
insert into uitvoeringen   values ('XML','18-09-2000',NULL,'MAASTRICHT');
insert into uitvoeringen   values ('OAG','27-09-2000',7902,'DE MEERN'  );

insert into uitvoeringen   values ('ERM','15-01-2001',NULL, NULL       );
insert into uitvoeringen   values ('PRO','19-02-2001',NULL,'DE MEERN'  );
insert into uitvoeringen   values ('RSO','24-02-2001',7788,'UTRECHT'   );

alter table uitvoeringen enable primary key;

REM ==========================================================
REM Tabel INSCHRIJVINGEN (CURSIST,CURSUS,BEGINDATUM,EVALUATIE)
REM ==========================================================

truncate table inschrijvingen;

insert into inschrijvingen values (7499,'S02','12-04-1999',4   );
insert into inschrijvingen values (7934,'S02','12-04-1999',5   );
insert into inschrijvingen values (7698,'S02','12-04-1999',4   );
insert into inschrijvingen values (7876,'S02','12-04-1999',2   );
insert into inschrijvingen values (7788,'S02','04-10-1999',NULL);
insert into inschrijvingen values (7839,'S02','04-10-1999',3   );
insert into inschrijvingen values (7902,'S02','04-10-1999',4   );
insert into inschrijvingen values (7902,'S02','13-12-1999',NULL);
insert into inschrijvingen values (7698,'S02','13-12-1999',NULL);
insert into inschrijvingen values (7521,'OAG','10-08-1999',4   );
insert into inschrijvingen values (7900,'OAG','10-08-1999',4   );
insert into inschrijvingen values (7902,'OAG','10-08-1999',5   );
insert into inschrijvingen values (7844,'OAG','27-09-2000',5   );
insert into inschrijvingen values (7499,'JAV','13-12-1999',2   );
insert into inschrijvingen values (7782,'JAV','13-12-1999',5   );
insert into inschrijvingen values (7876,'JAV','13-12-1999',5   );
insert into inschrijvingen values (7788,'JAV','13-12-1999',5   );
insert into inschrijvingen values (7839,'JAV','13-12-1999',4   );
insert into inschrijvingen values (7566,'JAV','01-02-2000',3   );
insert into inschrijvingen values (7788,'JAV','01-02-2000',4   );
insert into inschrijvingen values (7698,'JAV','01-02-2000',5   );
insert into inschrijvingen values (7900,'XML','03-02-2000',4   );
insert into inschrijvingen values (7499,'XML','03-02-2000',5   );
insert into inschrijvingen values (7566,'PLS','11-09-2000',NULL);
insert into inschrijvingen values (7499,'PLS','11-09-2000',NULL);
insert into inschrijvingen values (7876,'PLS','11-09-2000',NULL);

REM =============================================================
REM Tabel HISTORIE
REM (MNR,BEGINJAAR,BEGINDATUM,EINDDATUM,AFD,MAANDSAL,OPMERKINGEN)
REM Nieuw in 3e editie
REM =============================================================

alter table historie disable primary key cascade;
truncate table historie;

insert into historie values (7369,2000,'01-01-2000','01-02-2000',40, 950,
                             '');
insert into historie values (7369,2000,'01-02-2000', NULL       ,20, 800,
           'Overgang naar opleidingen, met salaris"correctie" 150');
--                          ============================================
insert into historie values (7499,1988,'01-06-1988','01-07-1989',30,1000,
                             '');
insert into historie values (7499,1989,'01-07-1989','01-12-1993',30,1300,
                             '');
insert into historie values (7499,1993,'01-12-1993','01-10-1995',30,1500,
                             '');
insert into historie values (7499,1995,'01-10-1995','01-11-1999',30,1700,
                             '');
insert into historie values (7499,1999,'01-11-1999', NULL       ,30,1600,
           'Targets al weer niet gehaald; salarisverlaging');
--                          ============================================
insert into historie values (7521,1986,'01-10-1986','01-08-1987',20,1000,
                             '');
insert into historie values (7521,1987,'01-08-1987','01-01-1989',30,1000,
           'Overgang naar afdeling verkoop op eigen verzoek');
insert into historie values (7521,1989,'01-01-1989','15-12-1992',30,1150,
                             '');
insert into historie values (7521,1992,'15-12-1992','01-10-1994',30,1250,
                             '');
insert into historie values (7521,1994,'01-10-1994','01-10-1997',20,1250,
                             '');
insert into historie values (7521,1997,'01-10-1997','01-02-2000',30,1300,
                             '');
insert into historie values (7521,2000,'01-02-2000', NULL       ,30,1250,
                             '');
--                          ============================================
insert into historie values (7566,1982,'01-01-1982','01-12-1982',20, 900,
                             '');
insert into historie values (7566,1982,'01-12-1982','15-08-1984',20, 950,
                             '');
insert into historie values (7566,1984,'15-08-1984','01-01-1986',30,1000,
           'Niet zo geschikt als docent; dan maar naar verkoop!');
insert into historie values (7566,1986,'01-01-1986','01-07-1986',30,1175,
           'Verkoop is ook al niet zo''n succes...');
insert into historie values (7566,1986,'01-07-1986','15-03-1987',10,1175,
                             '');
insert into historie values (7566,1987,'15-03-1987','01-04-1987',10,2200,
                             '');
insert into historie values (7566,1987,'01-04-1987','01-06-1989',10,2300,
                             '');
insert into historie values (7566,1989,'01-06-1989','01-07-1992',40,2300,
           'Van hoofdkantoor naar personeelszaken; salaris blijft 2300');
insert into historie values (7566,1992,'01-07-1992','01-11-1992',40,2450,
                             '');
insert into historie values (7566,1992,'01-11-1992','01-09-1994',20,2600,
           'Terug naar afdeling opleidingen, als hoofd');
insert into historie values (7566,1994,'01-09-1994','01-03-1995',20,2550,
                             '');
insert into historie values (7566,1995,'01-03-1995','15-10-1999',20,2750,
                             '');
insert into historie values (7566,1999,'15-10-1999', NULL       ,20,2975,
                             '');
--                          ============================================
insert into historie values (7654,1999,'01-01-1999','15-10-1999',30,1100,
           'Senior verkoper; zou wel eens een aanwinst kunnen zijn?');
insert into historie values (7654,1999,'15-10-1999', NULL       ,30,1250,
           'Valt toch een beetje tegen.');
--                          ============================================
insert into historie values (7698,1982,'01-06-1982','01-01-1983',30, 900,
                             '');
insert into historie values (7698,1983,'01-01-1983','01-01-1984',30,1275,
                             '');
insert into historie values (7698,1984,'01-01-1984','15-04-1985',30,1500,
                             '');
insert into historie values (7698,1985,'15-04-1985','01-01-1986',30,2100,
                             '');
insert into historie values (7698,1986,'01-01-1986','15-10-1989',30,2200,
                             '');
insert into historie values (7698,1989,'15-10-1989', NULL       ,30,2850,
           'Gepromoveerd tot hoofd van de afdeling verkoop');
--                          ============================================
insert into historie values (7782,1988,'01-07-1988', NULL       ,10,2450,
           'Aangenomen als manager voor het hoofdkantoor');
--                          ============================================
insert into historie values (7788,1982,'01-07-1982','01-01-1983',20, 900,
                             '');
insert into historie values (7788,1983,'01-01-1983','15-04-1985',20, 950,
                             '');
insert into historie values (7788,1985,'15-04-1985','01-06-1985',40, 950,
           'Overgang naar personeelszaken, zonder salarisverhoging');
insert into historie values (7788,1985,'01-06-1985','15-04-1986',40,1100,
                             '');
insert into historie values (7788,1986,'15-04-1986','01-05-1986',20,1100,
                             '');
insert into historie values (7788,1986,'01-05-1986','15-02-1987',20,1800,
                             '');
insert into historie values (7788,1987,'15-02-1987','01-12-1989',20,1250,
           'Salarisverlaging met 550, vanwege onvoldoende prestaties');
insert into historie values (7788,1989,'01-12-1989','15-10-1992',20,1350,
                             '');
insert into historie values (7788,1992,'15-10-1992','01-01-1998',20,1400,
                             '');
insert into historie values (7788,1998,'01-01-1998','01-01-1999',20,1700,
                             '');
insert into historie values (7788,1999,'01-01-1999','01-07-1999',20,1800,
                             '');
insert into historie values (7788,1999,'01-07-1999','01-06-2000',20,1800,
                             '');
insert into historie values (7788,2000,'01-06-2000', NULL       ,20,3000,
                             '');
--                          ============================================
insert into historie values (7839,1982,'01-01-1982','01-08-1982',30,1000,
           'Oprichter en eerste werknemer van het bedrijf');
insert into historie values (7839,1982,'01-08-1982','15-05-1984',30,1200,
                             '');
insert into historie values (7839,1984,'15-05-1984','01-01-1985',30,1500,
                             '');
insert into historie values (7839,1985,'01-01-1985','01-07-1985',30,1750,
                             '');
insert into historie values (7839,1985,'01-07-1985','01-11-1985',10,2000,
           'Hoofdkantoor als nieuwe zelfstandige afdeling opgericht');
insert into historie values (7839,1985,'01-11-1985','01-02-1986',10,2200,
                             '');
insert into historie values (7839,1986,'01-02-1986','15-06-1989',10,2500,
                             '');
insert into historie values (7839,1989,'15-06-1989','01-12-1993',10,2900,
                             '');
insert into historie values (7839,1993,'01-12-1993','01-09-1995',10,3400,
                             '');
insert into historie values (7839,1995,'01-09-1995','01-10-1997',10,4200,
                             '');
insert into historie values (7839,1997,'01-10-1997','01-10-1998',10,4500,
                             '');
insert into historie values (7839,1998,'01-10-1998','01-11-1999',10,4800,
                             '');
insert into historie values (7839,1999,'01-11-1999','15-02-2000',10,4900,
                             '');
insert into historie values (7839,2000,'15-02-2000', NULL       ,10,5000,
                             '');
--                          ============================================
insert into historie values (7844,1995,'01-05-1995','01-01-1997',30, 900,
                             '');
insert into historie values (7844,1998,'15-10-1998','01-11-1998',10,1200,
           'Project (van een halve maand) voor het hoofdkantoor');
insert into historie values (7844,1998,'01-11-1998','01-01-2000',30,1400,
                             '');
insert into historie values (7844,2000,'01-01-2000', NULL       ,30,1500,
                             '');
--                          ============================================
insert into historie values (7876,2000,'01-01-2000','01-02-2000',20, 950,
                             '');
insert into historie values (7876,2000,'01-02-2000', NULL       ,20,1100,
                             '');
--                          ============================================
insert into historie values (7900,2000,'01-07-2000', NULL       ,30, 800,
           'Junior verkoper -- moet nog veel leren...');
--                          ============================================
insert into historie values (7902,1998,'01-09-1998','01-10-1998',40,1400,
                             '');
insert into historie values (7902,1998,'01-10-1998','15-03-1999',30,1650,
                             '');
insert into historie values (7902,1999,'15-03-1999','01-01-2000',30,2500,
                             '');
insert into historie values (7902,2000,'01-01-2000','01-08-2000',30,3000,
                             '');
insert into historie values (7902,2000,'01-08-2000', NULL       ,20,3000,
                             '');
--                          ============================================
insert into historie values (7934,1998,'01-02-1998','01-05-1998',10,1275,
                             '');
insert into historie values (7934,1998,'01-05-1998','01-02-1999',10,1280,
                             '');
insert into historie values (7934,1999,'01-02-1999','01-01-2000',10,1290,
                             '');
insert into historie values (7934,2000,'01-01-2000', NULL       ,10,1300,
                             '');

alter table historie enable primary key;

REM ==============================
REM Enable foreign key constraints
REM ==============================

alter table medewerkers    enable constraint M_CHEF_FK;
alter table medewerkers    enable constraint M_AFD_FK;
alter table afdelingen     enable constraint A_HOOFD_FK;
alter table uitvoeringen   enable constraint U_CURSUS_FK;
alter table uitvoeringen   enable constraint U_DOCENT_FK;
alter table inschrijvingen enable constraint I_UITV_FK;
alter table inschrijvingen enable constraint I_CURSIST_FK;
alter table historie       enable constraint H_MNR_FK;
alter table historie       enable constraint H_AFD_FK;

REM ============================================
REM Verzamel object-statistics voor de optimizer
REM ============================================

execute dbms_stats.gather_schema_stats(ownname => user, cascade => true);
