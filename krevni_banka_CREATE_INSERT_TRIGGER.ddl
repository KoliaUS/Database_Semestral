/* Zalozeni tabulek */
create table CEABINICSEM.kontaktni_informace
(
    kont_id     int primary key not null auto_increment,
    jmeno varchar(30),
    prijmeni varchar(30),
    tel_cislo   varchar(14),
    email       varchar(40),
    bydliste    varchar(50),
    rodne_cislo varchar(11)

);

create table CEABINICSEM.role
(
  role_id  int primary key not null auto_increment,
  nazev varchar(30)
);

create table CEABINICSEM.krevni_skupina
(
  krev_id int primary key not null auto_increment,
  nazev varchar(3)
);

create table CEABINICSEM.oceneni
(
  oceneni_id int primary key not null auto_increment,
  nazev varchar(100),
  pocet int
);

create table CEABINICSEM.personal
(
  personal_id int primary key not null auto_increment,
  kont_id int,
  role_id int,


  foreign key (role_id) references role (role_id),
  foreign key (kont_id) references kontaktni_informace (kont_id)

);

create table CEABINICSEM.pacient
(
 pacient_id int primary key not null auto_increment,
 kont_id int,
 krev_id int,


 foreign key (krev_id) references krevni_skupina (krev_id),
 foreign key (kont_id) references kontaktni_informace (kont_id)
);

create table CEABINICSEM.darce
(
  darce_id int primary key not null auto_increment,
  kont_id int,
  krev_id int,
  prvni_odber date,
  pocet_odberu int,
  oceneni_id int,


  foreign key (krev_id) references krevni_skupina (krev_id),
  foreign key (kont_id) references kontaktni_informace(kont_id),
  foreign key (oceneni_id) references oceneni (oceneni_id)
);

create table CEABINICSEM.odber
(
    odber_id int primary key not null auto_increment,
    datum_prov date,
    personal_id int,
    darce_id int,
    prohlidka varchar(100),
    uspech bool,
    odmitnuti_duvod varchar(50),
    odmitnuti_od date,
    odmitnuti_do date,

    foreign key (personal_id) references personal (personal_id),
    foreign key (darce_id) references darce (darce_id)

);

create table CEABINICSEM.transfuzni_stav
(
    tp_stav_id int primary key not null auto_increment,
    stav varchar (50)
);

create table CEABINICSEM.transfuzni_druh
(
  tp_druh_id int primary key not null auto_increment,
  druh varchar(50)
);

create table CEABINICSEM.transfuzni_pripravek
(
  tp_id int primary key not null auto_increment,
  tp_stav_id int,
  tp_druh_id int,
  odber_id int,

  foreign key (tp_stav_id) references transfuzni_stav(tp_stav_id),
  foreign key (tp_druh_id) references transfuzni_druh(tp_druh_id),
  foreign key (odber_id) references odber (odber_id)
);

create table CEABINICSEM.podany_typ
(
    pod_id int primary key not null auto_increment,
    tp_id int,
    pacient_id int,
    cas_podani datetime,

    foreign key (tp_id) references transfuzni_pripravek (tp_id),
    foreign key (pacient_id) references pacient(pacient_id)
);


/* Zalozeni triggeru na oceneni*/
create trigger pocet_odberu after insert on odber
    for each row

    begin
        declare oceneni_id int;
        declare darce_pocet int;
        declare d_v int;
        set d_v = (select distinct darce.darce_id from darce join odber on odber.darce_id = darce.darce_id where odber.odber_id = new.odber_id);
    if (new.uspech) then
    update darce
    set pocet_odberu = pocet_odberu + 1
    where darce.darce_id = new.darce_id;
    set darce_pocet = (select distinct darce.pocet_odberu from darce where darce_id = d_v);
    set oceneni_id = (select distinct  oceneni.oceneni_id from oceneni where oceneni.pocet = darce_pocet);
    if (oceneni_id is not null) then
        update darce set oceneni_id = oceneni_id where darce_id= d_v;
    end if;
    end if;
    end;
/* Zalozeni triggeru na spravnou krevni skupinu*/
delimiter //
create trigger `spravna_krevni_skupina` before insert on podany_typ
for each row
begin
    declare darce_ks int;
    declare pacient_ks int;
    set darce_ks = (select distinct krev_id from darce join odber o on darce.darce_id = o.darce_id join transfuzni_pripravek tp on o.odber_id = tp.odber_id where tp_id=new.tp_id);
    set pacient_ks = (select krev_id from pacient where pacient_id=new.pacient_id);
    if (darce_ks != pacient_ks) then
        signal sqlstate '45000' -- note: 45000 je unhandled user-defined exception
        set message_text = 'krevní skupiny dárce a pacienta se neshoduji';
    end if;
end //
delimiter ;
/* Zalozeni procedury na vyrad_tp 3. bonus ukol*/

delimiter //
create procedure vyrad_tp()
begin
update transfuzni_pripravek
join odber o on o.odber_id = transfuzni_pripravek.odber_id
set tp_stav_id = 2
where tp_druh_id= 2 and datum_prov < date_add(curdate(), interval -5 day ) and tp_stav_id = 3
or tp_druh_id=1 and datum_prov < date_add(curdate(), interval -6 week )  and tp_stav_id = 3
or tp_druh_id = 3 and datum_prov < date_add(curdate(), interval -3 year )  and tp_stav_id = 3
or tp_druh_id = 4 and datum_prov < date_add(curdate(), interval -1 day )  and tp_stav_id = 3;

end //
delimiter ;

/* Zalozeni triggeru pro transfuzni pripravek podany*/
delimiter //
create trigger podany_tp after insert on podany_typ
    for each row

    begin
        if new.tp_id is not null then
            update transfuzni_pripravek
                set transfuzni_pripravek.tp_stav_id = 1
                where tp_id=NEW.tp_id;
        end if;
    end //
delimiter ;

/* Naplneni kontaktni informace*/

insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Lissi', 'Ferentz', '516 499 2007', 'lferentz0@yellowbook.com', '37603 Bluejay Place', '0730494152');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Luelle', 'De Ruel', '819 962 3010', 'lderuel1@omniture.com', '22 Red Cloud Place', '0679971807');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Rowe', 'Powderham', '397 553 0957', 'rpowderham2@weibo.com', '8 Meadow Vale Alley', '7752139807');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Nico', 'Matonin', '377 862 0636', 'nmatonin3@who.int', '011 Westridge Street', '8304190613');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Tessie', 'Ive', '966 368 5814', 'tive4@narod.ru', '13794 International Plaza', '1241513562');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Octavius', 'Borghese', '928 311 1438', 'oborghese5@ihg.com', '4643 Ilene Park', '1864474556');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Marlane', 'Sancho', '976 912 1462', 'msancho6@networksolutions.com', '57910 Rusk Center', '0697172651');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Codie', 'Standring', '698 573 3821', 'cstandring7@sciencedaily.com', '37 Sutteridge Court', '0513523979');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Micki', 'Campion', '982 936 7003', 'mcampion8@omniture.com', '669 7th Way', '9827309862');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Desirae', 'Utterson', '984 597 0731', 'dutterson9@lulu.com', '35 Nova Circle', '7881106220');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Holly-anne', 'Isles', '825 981 6308', 'hislesa@symantec.com', '768 Del Sol Junction', '5745858281');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Maryjane', 'Straughan', '228 953 2439', 'mstraughanb@wikimedia.org', '5 Rowland Terrace', '4401465598');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Tedman', 'Herrieven', '210 870 3049', 'therrievenc@nymag.com', '61663 Starling Court', '9610557929');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Norrie', 'Penny', '803 666 1072', 'npennyd@wordpress.org', '6210 Esker Hill', '4120789101');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Nessie', 'Duligal', '736 319 4120', 'nduligale@google.com.au', '0288 Lindbergh Street', '0969934556');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Augusta', 'Scrace', '548 866 4239', 'ascracef@blogspot.com', '300 Sherman Pass', '6238344180');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Brianne', 'Measom', '567 793 9977', 'bmeasomg@opera.com', '9 Katie Center', '4137582564');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Fayina', 'Crichmere', '256 950 5100', 'fcrichmereh@mapquest.com', '53 Briar Crest Pass', '3898780961');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Willie', 'Danieli', '939 925 3697', 'wdanielii@fotki.com', '6 Dovetail Park', '3070159176');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Mose', 'Childes', '773 359 2943', 'mchildesj@tumblr.com', '8 Lake View Trail', '7282714819');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Corney', 'Thursfield', '320 402 6836', 'cthursfieldk@canalblog.com', '54998 Hansons Junction', '7590187666');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Thorin', 'Kinchley', '554 733 7838', 'tkinchleyl@time.com', '24456 Debs Center', '4601932076');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Harlene', 'Rutt', '987 875 8765', 'hruttm@craigslist.org', '332 Lyons Avenue', '7408162798');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Elena', 'Rickersy', '676 643 9409', 'erickersyn@samsung.com', '598 Manitowish Court', '3361957516');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Abbi', 'Di Napoli', '106 491 4001', 'adinapolio@state.gov', '52 Mcbride Alley', '3845914386');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Cassondra', 'Irlam', '714 848 6904', 'cirlamp@squidoo.com', '61208 Sunfield Terrace', '8931172338');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Ozzie', 'Cornwall', '510 452 9097', 'ocornwallq@biblegateway.com', '96 Gina Crossing', '2338831373');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Lukas', 'Cicullo', '534 656 2469', 'lcicullor@indiegogo.com', '8 Westport Crossing', '5132386806');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Dodi', 'Keneleyside', '874 419 2364', 'dkeneleysides@com.com', '224 Artisan Hill', '7477337224');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Decca', 'Whatmough', '222 447 3924', 'dwhatmought@admin.ch', '400 Golf Course Court', '9522239771');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Lawton', 'Judkin', '735 354 2580', 'ljudkinu@e-recht24.de', '280 Dexter Pass', '3412195359');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Jennilee', 'Nuccitelli', '903 151 0219', 'jnuccitelliv@spotify.com', '24843 Harper Pass', '4177738964');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Josy', 'Checchetelli', '518 669 0301', 'jchecchetelliw@adobe.com', '902 Rigney Hill', '8278708770');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Judas', 'des Remedios', '782 127 6269', 'jdesremediosx@sciencedaily.com', '9 Colorado Trail', '7537654271');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Tedie', 'Sherwen', '615 570 5500', 'tsherweny@ucsd.edu', '25 Fieldstone Terrace', '7363301816');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Porter', 'Gostall', '724 627 6532', 'pgostallz@xing.com', '33660 Westerfield Avenue', '7337560508');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Misti', 'Munks', '886 917 8064', 'mmunks10@lulu.com', '9497 Mosinee Pass', '7542571982');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Loni', 'Hatwell', '982 223 1985', 'lhatwell11@topsy.com', '2238 Monterey Road', '1903253462');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Herschel', 'Darnborough', '969 366 9538', 'hdarnborough12@miibeian.gov.cn', '29451 Del Sol Way', '6931856235');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Major', 'Licas', '383 774 4874', 'mlicas13@hc360.com', '34 Mariners Cove Plaza', '7506520117');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Devan', 'MacElholm', '931 231 9936', 'dmacelholm14@yahoo.com', '1448 Caliangt Alley', '4290820182');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Caye', 'Casswell', '291 784 8296', 'ccasswell15@seattletimes.com', '898 Sundown Crossing', '2890249379');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Sile', 'De Blase', '889 637 8028', 'sdeblase16@ning.com', '7757 Commercial Alley', '7295412689');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Benni', 'Trimnell', '160 862 9317', 'btrimnell17@amazon.de', '28 Wayridge Hill', '9587578864');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Allegra', 'Matyushkin', '118 170 0694', 'amatyushkin18@boston.com', '7278 Waywood Hill', '1565389204');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Forest', 'Ewence', '112 812 8687', 'fewence19@berkeley.edu', '91290 Leroy Circle', '8073203723');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Benjamen', 'Dutchburn', '760 772 6600', 'bdutchburn1a@over-blog.com', '65 Warner Parkway', '2424229600');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Tove', 'Denman', '323 221 5487', 'tdenman1b@un.org', '9432 Nobel Center', '0840866003');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Brier', 'Provest', '375 559 8205', 'bprovest1c@deliciousdays.com', '00973 Emmet Lane', '0620993979');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Elnar', 'Jeafferson', '887 536 4802', 'ejeafferson1d@moonfruit.com', '262 Bobwhite Pass', '3231161428');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Nikolai', 'Pottes', '304 713 9933', 'npottes1e@ustream.tv', '44 Lindbergh Hill', '0196142504');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Erma', 'Beeston', '402 469 8234', 'ebeeston1f@arstechnica.com', '51 5th Street', '8463511678');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Dun', 'Mc Cahey', '610 372 0850', 'dmccahey1g@globo.com', '9 Twin Pines Trail', '3364921776');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Heidie', 'Andrieux', '949 735 5611', 'handrieux1h@seattletimes.com', '20358 Eastwood Junction', '5106726204');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Roanna', 'Degg', '406 227 7799', 'rdegg1i@wikispaces.com', '614 Di Loreto Terrace', '9809893094');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Birdie', 'Gorger', '670 559 9049', 'bgorger1j@is.gd', '807 Fordem Point', '2651561592');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Monica', 'Troman', '407 750 0584', 'mtroman1k@sourceforge.net', '0 Derek Court', '5600514212');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Tobe', 'McGilroy', '597 206 8692', 'tmcgilroy1l@mac.com', '52 Manley Lane', '6910835158');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Craggy', 'Arnecke', '804 792 1924', 'carnecke1m@techcrunch.com', '91 Northport Terrace', '5237118445');
insert into kontaktni_informace (jmeno, prijmeni, tel_cislo, email, bydliste, rodne_cislo) values ('Hill', 'Candie', '749 697 4465', 'hcandie1n@example.com', '56912 Jana Hill', '6292477134');

/* Naplneni krevni skupiny */

insert into krevni_skupina (nazev) values ('A+');
insert into krevni_skupina (nazev) values ('A-');
insert into krevni_skupina (nazev) values ('B+');
insert into krevni_skupina (nazev) values ('B-');
insert into krevni_skupina (nazev) values ('AB+');
insert into krevni_skupina (nazev) values ('AB-');
insert into krevni_skupina (nazev) values ('0+');
insert into krevni_skupina (nazev) values ('0-');

/* Naplneni role personalu */

insert into role (nazev) values ('doktor');
insert into role (nazev) values ('sestra');
insert into role (nazev) values ('bratr');


/* Naplneni oceneni */

insert into oceneni (nazev, pocet) values ('Krůpěj krve',1);
insert into oceneni (nazev, pocet) values ('Bronzová medaile Prof. MUDr. Jana Janského',10);
insert into oceneni (nazev, pocet) values ('Stříbrná medaile Prof. MUDr. Jana Janského',20);
insert into oceneni (nazev, pocet) values ('Zlatá medaile Prof. MUDr. Jana Janského',40);
insert into oceneni (nazev, pocet) values ('Zlatý kříž ČČK 3. třídy',80);
insert into oceneni (nazev, pocet) values ('Zlatý kříž ČČK 2. třídy',120);
insert into oceneni (nazev, pocet) values ('Zlatý kříž ČČK 1. třídy',160);
insert into oceneni (nazev, pocet) values ('Plaketa ČČK Dar krve - dar života',250);

/* Naplneni transfuzni druh */

insert into transfuzni_druh (druh) values ('erytrocyty');
insert into transfuzni_druh (druh) values ('trombocyty');
insert into transfuzni_druh (druh) values ('plazma');
insert into transfuzni_druh (druh) values ('granulocyty');


/* Naplneni transfuzni stav */

insert into transfuzni_stav (stav) values ('Využito');
insert into transfuzni_stav (stav) values ('Zničeno');
insert into transfuzni_stav (stav) values ('Nevyužito');


/* Naplneni personal */
insert into personal (role_id, kont_id) values (1, 1);
insert into personal (role_id, kont_id) values (2, 2);
insert into personal (role_id, kont_id) values (2, 3);
insert into personal (role_id, kont_id) values (1, 4);
insert into personal (role_id, kont_id) values (3, 5);
insert into personal (role_id, kont_id) values (1, 6);
insert into personal (role_id, kont_id) values (2, 7);
insert into personal (role_id, kont_id) values (2, 8);
insert into personal (role_id, kont_id) values (3, 9);
insert into personal (role_id, kont_id) values (3, 10);
insert into personal (role_id, kont_id) values (2, 11);
insert into personal (role_id, kont_id) values (1, 12);
insert into personal (role_id, kont_id) values (2, 13);
insert into personal (role_id, kont_id) values (3, 14);
insert into personal (role_id, kont_id) values (1, 15);
insert into personal (role_id, kont_id) values (1, 16);
insert into personal (role_id, kont_id) values (2, 17);
insert into personal (role_id, kont_id) values (3, 18);
insert into personal (role_id, kont_id) values (1, 19);
insert into personal (role_id, kont_id) values (3, 20);

/* Naplneni pacientu */
insert into pacient (krev_id, kont_id) values (7, 41);
insert into pacient (krev_id, kont_id) values (1, 42);
insert into pacient (krev_id, kont_id) values (3, 43);
insert into pacient (krev_id, kont_id) values (2, 44);
insert into pacient (krev_id, kont_id) values (5, 45);
insert into pacient (krev_id, kont_id) values (1, 46);
insert into pacient (krev_id, kont_id) values (5, 47);
insert into pacient (krev_id, kont_id) values (6, 48);
insert into pacient (krev_id, kont_id) values (8, 49);
insert into pacient (krev_id, kont_id) values (6, 50);
insert into pacient (krev_id, kont_id) values (8, 51);
insert into pacient (krev_id, kont_id) values (4, 52);
insert into pacient (krev_id, kont_id) values (8, 53);
insert into pacient (krev_id, kont_id) values (2, 54);
insert into pacient (krev_id, kont_id) values (8, 55);
insert into pacient (krev_id, kont_id) values (1, 56);
insert into pacient (krev_id, kont_id) values (6, 57);
insert into pacient (krev_id, kont_id) values (5, 58);
insert into pacient (krev_id, kont_id) values (5, 59);
insert into pacient (krev_id, kont_id) values (1, 60);

/* Naplneni darce */
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (8, 21, '2021-10-14', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (4, 22, '2021-11-20', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (1, 23, '2021-09-22', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (4, 24, '2021-05-27', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (2, 25, '2021-06-21', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (4, 26, '2021-01-18', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (8, 27, '2021-11-05', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (7, 28, '2021-10-31', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (5, 29, '2021-08-09', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (1, 30, '2021-07-07', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (1, 31, '2021-05-22', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (7, 32, '2021-04-26', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (4, 33, '2021-03-05', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (1, 34, '2021-01-15', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (1, 35, '2021-12-29', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (6, 36, '2021-07-24', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (2, 37, '2021-02-04', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (4, 38, '2021-02-02', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (4, 39, '2021-03-18', 1, 1);
insert into darce (krev_id, kont_id, prvni_odber, oceneni_id, pocet_odberu) values (4, 40, '2021-09-15', 1, 1);


/* Naplneni odber */
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2020-07-27', 8, 8, 'Pacient v pořádku, tlak změřen a vše je v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2020-05-08', 20, 14, 'Po prohlídce vše v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2020-09-07', 9, 19, 'Vše v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2020-12-01', 18, 17, 'Pacient se cítí v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2020-02-18', 19, 15, 'Vše v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2020-02-20', 19, 11, 'Vše v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2020-02-20', 20, 10, 'Vše v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2020-02-20', 5, 19, 'Vše v pořádku', true);

insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech, odmitnuti_duvod, odmitnuti_od, odmitnuti_do) values ('2020-11-04', 19, 15, 'Pacient měl hřipku', false, 'chřipka', '2020-11-04', '2020-11-18');
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech, odmitnuti_duvod, odmitnuti_od, odmitnuti_do) values ('2020-11-04', 19, 1, 'Covid', false, 'Covid-19', '2020-12-04', '2020-12-18');
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech, odmitnuti_duvod, odmitnuti_od, odmitnuti_do) values ('2020-05-07', 5, 2, 'Pacient se necítil dobře', false, 'Nemoc', '2020-05-07', '2020-05-14');
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech, odmitnuti_duvod, odmitnuti_od, odmitnuti_do) values ('2020-07-14', 6, 9, 'Pacient oznámil, že má horečku a nedostavil se', false, 'Nedostavil se', '2020-07-14', '2020-08-14');


insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2022-01-07', 16, 15, 'Po prohlídce vše v pořádku a pacient se cití dobře', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-12-17', 1, 7, 'Vše v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-12-30', 2, 14, 'Pacient v pořádku, tlak změřen a vše je v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-04-06', 6, 8, 'Pacient po prohlídce - tlak mírně vysoký', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-04-13', 18, 11, 'Pacient se cití dobře a tlak se v pořádky', true);

insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech, odmitnuti_duvod, odmitnuti_od, odmitnuti_do) values ('2022-01-01', 2, 16, 'Pacient se nedostavil na objednani', false, 'Nedostavil', '2022-01-01', '2022-01-07');
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech, odmitnuti_duvod, odmitnuti_od, odmitnuti_do) values ('2022-01-04', 5, 13, 'Pacient oznámil, že má teplotu', false, 'Teplota', '2022-01-04', '2022-01-18');
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech, odmitnuti_duvod, odmitnuti_od, odmitnuti_do) values ('2021-12-15', 4, 2, 'Pacient měl moc vysoký tlak', false, 'Tlak', '2021-12-15', '2021-12-30');
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech, odmitnuti_duvod, odmitnuti_od, odmitnuti_do) values ('2021-12-21', 5, 10, 'Pacient se nedostavil', false, 'Pacient se nedostavil', '2021-12-21', '2021-01-21');
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech, odmitnuti_duvod, odmitnuti_od) values ('2022-01-08', 2, 5, 'Pacient v cerny listine', false, 'Cerna listina', '2022-01-08');

insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-04-08', 2, 10, 'Vše v pořádku - tlak v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-04-01', 5, 9, 'vše v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-04-18', 6, 2, 'Prohlídka proběhla úspěšně', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-04-20', 6, 3, 'Prohlídka se provedla, pacient se cítí dobře', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech, odmitnuti_duvod, odmitnuti_od, odmitnuti_do) values ('2020-04-21', 7, 5, 'Pacient se nedostavil', false, 'Pacient se nedostavil', '2020-04-21', '2021-04-29');
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-12-25', 15, 3, 'Všechno v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-12-29', 17, 3, 'Všechno v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2022-01-03', 12, 3, 'Všechno v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2022-01-07', 15, 3, 'Všechno v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2022-01-09', 11, 3, 'Všechno v pořádku', true);

insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-12-20', 1, 6, 'Vše v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-12-31', 7, 9, 'Pacient se cítí dobře, tlak v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-12-24', 14, 15, 'Prohlídka proběhla - vše v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-12-23', 20, 2, 'Pacient má tlak v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2022-01-04', 3, 6, 'Pacient se cítí dobře a prohlídka proběhla v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2022-01-02', 16, 3, 'Vše v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-12-21', 14, 2, 'Vše ok', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-12-24', 9, 1, 'Pacient se cití dobře', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-12-24', 6, 3, 'Kontrola tlaku - ok', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-12-22', 2, 13, 'Pacientovi byl vymeren tlak a vse v poradku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-12-29', 9, 13, 'Pacient se cití dobře', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-12-31', 20, 5, 'Změřen tlak a teplota - vše ok', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2022-01-03', 17, 4, 'Pacientův stav je v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2022-01-02', 19, 15, 'Pacient se cítí dobře', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-12-30', 13, 14, 'Pacient - vše ok', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2022-01-03', 16, 7, 'Všechno v pořádku a prohlidka proběhla v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-12-24', 15, 4, 'Vše v pořádku', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2022-01-08', 14, 12, 'Pacient - bez problému', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2022-01-08', 13, 3, 'Pacient - tlak - ok', true);
insert into odber (datum_prov, personal_id, darce_id, prohlidka, uspech) values ('2021-12-20', 15, 14, 'Všechno v pořádku', true);


/* Naplneni transfuzni pripravek */

insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 1);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 2);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 3);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 4);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 5);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 1);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 2);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 3);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 4);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 5);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 3, 1);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 3, 2);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 3, 3);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 3, 4);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 3, 5);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 4, 1);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 4, 2);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 4, 3);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 4, 4);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 4, 5);

insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 10);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 11);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 12);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 13);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 14);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 10);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 11);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 12);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 13);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 14);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 3, 10);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 3, 11);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 3, 12);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 3, 13);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 3, 14);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 4, 10);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 4, 11);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 4, 12);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 4, 13);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 4, 14);

insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 30);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 31);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 32);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 33);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 34);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 35);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 36);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 37);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 38);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 39);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 40);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 41);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 42);

insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 4, 36);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 4, 37);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 4, 38);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 4, 39);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 4, 40);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 4, 41);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 4, 42);

insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 36);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 37);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 38);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 39);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 40);

insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 20);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 21);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 22);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 1, 23);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 20);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 21);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 22);
insert into transfuzni_pripravek (tp_stav_id, tp_druh_id, odber_id) values (3, 2, 23);

/* Naplneni podany_typ pacientovi */


insert into podany_typ (tp_id, pacient_id, cas_podani) values (60,12,'2022-01-04');
insert into podany_typ (tp_id, pacient_id, cas_podani) values (46,20,'2022-01-03');
insert into podany_typ (tp_id, pacient_id, cas_podani) values (49,20,'2021-12-25');
insert into podany_typ (tp_id, pacient_id, cas_podani) values (56,20,'2021-12-26');
insert into podany_typ (tp_id, pacient_id, cas_podani) values (2,2,'2021-04-21');
insert into podany_typ (tp_id, pacient_id, cas_podani) values (1,1,'2021-12-26');
insert into podany_typ (tp_id, pacient_id, cas_podani) values (3,12,'2020-09-07');
insert into podany_typ (tp_id, pacient_id, cas_podani) values (4,14,'2020-12-02');
insert into podany_typ (tp_id, pacient_id, cas_podani) values (5,6,'2020-02-19');
insert into podany_typ (tp_id, pacient_id, cas_podani) values (6,1,'2020-07-28');
insert into podany_typ (tp_id, pacient_id, cas_podani) values (7,2,'2020-05-09');

insert into podany_typ (tp_id, pacient_id, cas_podani) values (8,12,'2020-09-08');
insert into podany_typ (tp_id, pacient_id, cas_podani) values (9,4,'2020-12-01');
insert into podany_typ (tp_id, pacient_id, cas_podani) values (10,20,'2020-02-19');
insert into podany_typ (tp_id, pacient_id, cas_podani) values (11,1,'2020-07-28');
insert into podany_typ (tp_id, pacient_id, cas_podani) values (12,2,'2020-05-08');
insert into podany_typ (tp_id, pacient_id, cas_podani) values (13,12,'2020-09-08');
insert into podany_typ (tp_id, pacient_id, cas_podani) values (14,14,'2020-12-01');
insert into podany_typ (tp_id, pacient_id, cas_podani) values (15,20,'2020-02-19');
insert into podany_typ (tp_id, pacient_id, cas_podani) values (59,16,'2022-01-01');

