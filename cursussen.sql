REM =====================================================================
REM SQL*Plus script crecase.sql: maakt de casustabellen (met constraints)
REM Leerboek Oracle SQL, Lex de Haan
REM Derde editie, Academic Service 2004
REM =====================================================================

REM =================
REM Tabel MEDEWERKERS
REM =================

-- drop table medewerkers cascade constraints;

create table medewerkers
( mnr        NUMBER(4)    constraint M_PK
                          primary key
                          constraint M_MNR_CHK
                          check (mnr > 7000)
, naam       VARCHAR2(12) constraint M_NAAM_NN
                          not null
, voorl      VARCHAR2(5)  constraint M_VOORL_NN
                          not null
, functie    VARCHAR2(10)
, chef       NUMBER(4)    constraint M_CHEF_FK
                          references medewerkers
, gbdatum    DATE         constraint M_GEBDAT_NN
                          not null
, maandsal   NUMBER(6,2)  constraint M_MNDSAL_NN
                          not null
, comm       NUMBER(6,2)
, afd        NUMBER(2)    default 10
, constraint M_VERK_CHK   check
                          (decode(functie,'VERKOPER',0,1)
                           + nvl2(comm,              1,0) = 1)
) ;

REM ================
REM Tabel AFDELINGEN
REM ================

-- drop table afdelingen cascade constraints;

create table afdelingen
( anr     NUMBER(2)    constraint A_PK
                       primary key
                       constraint A_ANR_CHK
                       check (mod(anr,10) = 0)
, naam    VARCHAR2(20) constraint A_NAAM_NN
                       not null
                       constraint A_NAAM_UN
                       unique
                       constraint A_NAAM_CHK
                       check (naam = upper(naam))
, locatie VARCHAR2(20) constraint A_LOC_NN
                       not null
                       constraint A_LOC_CHK
                       check (locatie = upper(locatie))
, hoofd   NUMBER(4)    constraint A_HOOFD_FK
                       references medewerkers
) ;

alter table medewerkers
add  (constraint M_AFD_FK
      foreign key (afd)
      references afdelingen);

REM =============
REM Tabel SCHALEN
REM =============

-- drop table schalen cascade constraints;

create table schalen
( snr        NUMBER(2)   constraint S_PK
                         primary key
, ondergrens NUMBER(6,2) constraint S_ONDER_NN
                         not null
                         constraint S_ONDER_CHK
                         check (ondergrens >= 0)
, bovengrens NUMBER(6,2) constraint S_BOVEN_NN
                         not null
, toelage    NUMBER(6,2) constraint S_TOELG_NN
                         not null
, constraint S_OND_BOV   check
                         (ondergrens <= bovengrens)
) ;

REM ===============
REM Tabel CURSUSSEN 
REM ===============

-- drop table cursussen cascade constraints;

create table cursussen
( code         VARCHAR2(4)  constraint C_PK
                            primary key
, omschrijving VARCHAR2(50) constraint C_OMSCHR_NN
                            not null
, type         CHAR(3)      constraint C_TYPE_NN
                            not null
, lengte       NUMBER(2)    constraint C_LENGTE_NN
                            not null
, constraint   C_CODE_CHK   check
                            (code = upper(code))
, constraint   C_TYPE_CHK   check
                            (type in ('ALG','BLD','DSG'))
) ;

REM ==================
REM Tabel UITVOERINGEN
REM ==================

-- drop table uitvoeringen cascade constraints;

create table uitvoeringen
( cursus      VARCHAR2(4)  constraint U_CURSUS_NN
                           not null
                           constraint U_CURSUS_FK
                           references cursussen
, begindatum  DATE         constraint U_BEGIN_NN
                           not null
, docent      NUMBER(4)    constraint U_DOCENT_FK
                           references medewerkers
, locatie     VARCHAR2(20)
, constraint  U_PK         primary key
                           (cursus,begindatum)
) ;

REM ====================
REM Tabel INSCHRIJVINGEN
REM ====================

-- drop table inschrijvingen cascade constraints;

create table inschrijvingen
( cursist      NUMBER(4)   constraint I_CURSIST_NN
                           not null
                           constraint I_CURSIST_FK
                           references medewerkers
, cursus       VARCHAR2(4) constraint I_CURSUS_NN
                           not null
, begindatum   DATE        constraint I_BEGIN_NN
                           not null
, evaluatie    NUMBER(1)   constraint I_EVAL_CHK
                           check (evaluatie in (1,2,3,4,5))
, constraint   I_PK        primary key
                           (cursist,cursus,begindatum)
, constraint   I_UITV_FK   foreign key
                           (cursus,begindatum)
                           references uitvoeringen
) ;

REM ======================================
REM Tabel HISTORIE (nieuw in derde editie)
REM ======================================

-- drop table  historie cascade constraints;

create table historie
( mnr         NUMBER(4)    constraint H_MNR_NN
                           not null
                           constraint H_MNR_FK
                           references medewerkers
                           on delete cascade
, beginjaar   NUMBER(4)    constraint H_BJAAR_NN
                           not null
, begindatum  DATE         constraint H_BEGIN_NN
                           not null
, einddatum   DATE
, afd         NUMBER(2)    constraint H_AFD_NN
                           not null
                           constraint H_AFD_FK
                           references afdelingen
, maandsal    NUMBER(6,2)  constraint H_SAL_NN
                           not null
, opmerkingen VARCHAR2(60)
, constraint  H_PK         primary key
                           (mnr,begindatum)
, constraint  H_BEG_EIND   check
                           (begindatum < einddatum)
) ;
