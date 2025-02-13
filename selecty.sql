/* 1. Vypište všechny dárce, kteří absolvovali alespoň jeden úspěšný odběr krve. */
select jmeno,prijmeni,darce.pocet_odberu from CEABINICSEM.darce join CEABINICSEM.kontaktni_informace ki on ki.kont_id = darce.kont_id
where pocet_odberu >=1;

/* 2. Vypište všechny pacienty s krevní skupinou „0“. */
select jmeno,prijmeni,nazev as krevni_skupina from (pacient join CEABINICSEM.kontaktni_informace ki on ki.kont_id = pacient.kont_id) join krevni_skupina on pacient.krev_id = krevni_skupina.krev_id
where nazev ='0+' or nazev = '0-';

/* 3. Vypište všechny dárce, kteří přišli na odběr v dubnu 2021. */
select jmeno,prijmeni,datum_prov as datum_odberu from (darce join kontaktni_informace ki on darce.kont_id = ki.kont_id) join odber on darce.darce_id=odber.darce_id
where  datum_prov between '2021-04-01' and '2021-04-31';

/* 4. Vypište všechny dárce, kteří mají za sebou alespoň jedno úspěšné a alespoň jedno neúspěšné
darování krve. */
select odber.darce_id,jmeno,prijmeni from odber join darce d on d.darce_id = odber.darce_id
join kontaktni_informace ki on ki.kont_id = d.kont_id
where uspech=0 and pocet_odberu>=1 group by d.darce_id;

/* 5. Zjistěte celkový počet odběrů krve provedený v roce 2020 */
select count(odber_id) as celkovy_pocet_odberu from odber
where datum_prov between '2020-01-01' and '2020-12-31' and uspech=true;



/* 6. Zjistěte celkový počet úspěšných a celkový počet neúspěšných odběrů v roce 2020. */
select  count(nullif(uspech, true)) as pocet_neuspesnych_provedenych_odberu, count(nullif(uspech, false)) as pocet_uspesnych_provedenych_odberu from odber
where datum_prov between '2020-01-01' and '2020-12-31';

/* 7. Vypište a seřaďte dárce podle počtu odběrů, od dárce s nejvyšším počtem odběrů, po dárce s nejnižším počtem odběrů */
select darce_id,jmeno,prijmeni,pocet_odberu from darce join kontaktni_informace ki on ki.kont_id = darce.kont_id order by pocet_odberu DESC;

/* 8. Vypište statistiku počtu odběrů z pohledu osoby přítomné u odběru. */
select nazev as pritomna_osoba,count(odber_id) as pocet_uspesnych_odberu from odber join personal p on odber.personal_id = p.personal_id join role r on r.role_id = p.role_id
where uspech = true group by nazev order by pocet_uspesnych_odberu DESC;

/* 9. Seřaďte transfuzní přípravky od nejčastěji připravovaného po nejméně připravovaný */
select druh as nazev,count(tp_id) as pocet_tp from transfuzni_pripravek join transfuzni_druh td on td.tp_druh_id = transfuzni_pripravek.tp_druh_id
group by nazev order by pocet_tp DESC ;

/* 10. Vypište počty zničených transfuzních přípravků za rok 2021. !!!!Nutno využít proceduru níže!!!!! */
select druh as nazev,count(tp_id) as pocet_znicenych_tp from transfuzni_pripravek join transfuzni_druh td on td.tp_druh_id = transfuzni_pripravek.tp_druh_id
join odber o on o.odber_id = transfuzni_pripravek.odber_id
where tp_stav_id = 2 and datum_prov between '2021-01-01' and '2021-12-31'
group by nazev order by pocet_znicenych_tp DESC ;

/* 11. Vypište dárce, jejichž plný odběr byl nevyužit a TP byly zničeny. Tedy odběr byl úspěšný, ale TP, které z něj vznikly exspirovaly a musely být zničeny */
select jmeno,prijmeni from kontaktni_informace join darce d on kontaktni_informace.kont_id = d.kont_id join odber o on d.darce_id = o.darce_id
join transfuzni_pripravek tp on o.odber_id = tp.odber_id
where tp_druh_id = 1 and tp_stav_id = 2 or tp_druh_id = 2 and tp_stav_id = 2 or
      tp_druh_id = 3 and tp_stav_id = 2 or tp_druh_id = 4 and tp_stav_id = 2 group by prijmeni, jmeno;

/* 12. Vypište nejvyšší počet podaných TP jednotlivému pacientovi s krevní skupinou „A+“. */
select count(pod_id) as pocet_podanych, jmeno,prijmeni,nazev as krevni_skupina from podany_typ join pacient p on p.pacient_id = podany_typ.pacient_id join krevni_skupina ks on ks.krev_id = p.krev_id
join kontaktni_informace ki on ki.kont_id = p.kont_id
where nazev = 'A+' group by prijmeni;

/* Bonus: 2.Napište UPDATE příkaz, který okamžitě označí veškeré TP s prošlou expirací jako „KE
ZNIČENÍ“ (nebo obdobné podle vašeho číselníku) */
update transfuzni_pripravek
join odber o on o.odber_id = transfuzni_pripravek.odber_id
set tp_stav_id = 2
where tp_druh_id= 2 and datum_prov < date_add(curdate(), interval -5 day ) and tp_stav_id =3
or tp_druh_id=1 and datum_prov < date_add(curdate(), interval -6 week ) and tp_stav_id =3
or tp_druh_id = 3 and datum_prov < date_add(curdate(), interval -3 year ) and tp_stav_id =3
or tp_druh_id = 4 and datum_prov < date_add(curdate(), interval -1 day ) and tp_stav_id =3;

/* Bonus: 3.Výše uvedený update převeďte do bezparametrové procedury vyrad_tp() -> v krevni_banka.dll  */
call vyrad_tp();


/* Bonus: 4.Napište UPDATE příkaz, který okamžitě označí všechny nespotřebované TP z minulého týdne
(minulý týden oproti času spuštění příkazu – musí to tedy být dynamické) jako „KE ZNIČENÍ“ (nebo obdobné podle vašeho číselníku). */
update transfuzni_pripravek
join odber o on o.odber_id = transfuzni_pripravek.odber_id
set tp_stav_id = 2
where tp_druh_id= 2 and datum_prov between date_add(curdate(), interval -1 week ) and now()
or tp_druh_id=1 and datum_prov between date_add(curdate(), interval -1 week ) and now()
or tp_druh_id = 3 and datum_prov between date_add(curdate(), interval -1 week ) and now()
or tp_druh_id = 4 and datum_prov between date_add(curdate(), interval -1 week ) and now();


