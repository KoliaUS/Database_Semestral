# Databázové systémy - Semestrální úloha

## Popis úlohy

Tato semestrální úloha se zaměřuje na návrh a implementaci databáze pro krevní banku, která bude sloužit k evidenci dárců, pacientů, odběrů, transfuzních přípravků a souvisejícího personálu v nemocnici.

### Cíl úlohy:
- Návrh a implementace databáze pro krevní banku.
- Implementace DDL (Data Definition Language) pro vytvoření tabulek a jejich naplnění.
- Implementace SQL dotazů pro získání specifikovaných informací z databáze.

## Požadavky na odevzdání

### Co odevzdat:
1. **Nákres DB** - fyzický datový model (např. v Lucidchartu nebo obdobném nástroji).
2. **DDL pro založení databáze** - soubor s příkazy pro vytvoření tabulek a vložení minimálně 20 záznamů do hlavních tabulek. DDL musí také obsahovat alespoň jednu proceduru nebo trigger.
3. **SQL dotazy** - soubor s SQL dotazy, které budou kompatibilní s vaší databází a označené číslem ze zadání.

### Forma odevzdání:
- Zazipovaný adresář pojmenovaný `<vase_prijmeni>_sem_uloha.zip` obsahující:
  - Diagram databáze.
  - Soubor s DDL příkazy pro vytvoření a naplnění databáze (.ddl).
  - Soubor s SQL SELECT dotazy (.sql), označené číslem ze zadání.
  
- Odevzdání do odevzdávárny ve skupině předmětu na platformě Teams.

### Poznámky:
- Soubor `.ddl` musí být spustitelný v celku.
- SQL dotazy musí být plně funkční na založené databázi.
- Důraz je kladen na formální stránku věci, např. konzistentní používání názvů (velká/velká písmena).

## Zadání

Navrhněte databázi pro **krevní banku** v nemocnici, která bude evidovat:

- **Dárce** - identifikační údaje, krevní skupina, datum prvního odběru a identifikace krevní skupiny.
- **Pacienti** - informace o pacientech, kteří obdrželi transfuzní přípravky (TP).
- **Personál** - údaje o zdravotnickém personálu (lékaři, sestrách, bratrech).
- **Odběry** - data o odběrech, stavy dárce a přítomné osoby u odběru.
- **Transfuzní přípravky (TP)** - údaje o přípravkách vytvořených z odběru krve, jejich životnost a zničení.
- **Historie podání TP** - evidování podaných TP pacientovi a jejich kompatibilita s krevní skupinou.

### Specifikace:

1. **Evidování odběrů** - úspěšné, neúspěšné a odmítnuté odběry.
2. **Transfuzní přípravky**:
   - Koncentrát červených krvinek.
   - Koncentrát krevních destiček.
   - Plazma.
   - Koncentrát bílých krvinek.
3. **Zničení transfuzních přípravků** - evidence zničených TP po uplynutí doby jejich životnosti.
4. **Ocenění dárců** - počet odběrů a udělená ocenění na základě počtu odběrů.

## SQL dotazy

### 1. Vypište všechny dárce, kteří absolvovali alespoň jeden úspěšný odběr krve. (1 bod)
### 2. Vypište všechny pacienty s krevní skupinou „0“. (1 bod)
### 3. Vypište všechny dárce, kteří přišli na odběr v dubnu 2021. (1 bod)
### 4. Vypište všechny dárce, kteří mají za sebou alespoň jedno úspěšné a alespoň jedno neúspěšné darování krve. (2 body)
### 5. Zjistěte celkový počet odběrů krve provedený v roce 2020. (1 bod)
### 6. Zjistěte celkový počet úspěšných a celkový počet neúspěšných odběrů v roce 2020. (2 body)
### 7. Vypište a seřaďte dárce podle počtu odběrů, od dárce s nejvyšším počtem odběrů, po dárce s nejnižším počtem odběrů. (1 bod)
### 8. Vypište statistiku počtu odběrů z pohledu osoby přítomné u odběru. (2 body)
### 9. Seřaďte transfuzní přípravky od nejčastěji připravovaného po nejméně připravovaný. (2 body)
### 10. Vypište počty zničených transfuzních přípravků za rok 2021. (2 body)
### 11. Vypište dárce, jejichž plný odběr byl nevyužit a TP byly zničeny. (3 body)
### 12. Vypište nejvyšší počet podaných TP jednotlivému pacientovi s krevní skupinou „A+“. (2 body)

## Poznámky k implementaci:
- Dbejte na správnou strukturu databáze a správné používání cizích klíčů pro integritu dat.
- Ujistěte se, že všechny SQL dotazy vrátí správné výsledky na vaší implementované databázi.
- Formátování kódu a dotazů je důležité pro čitelnost a údržbu.

## Odevzdání:
- Tento projekt odevzdejte ve formě `.zip` souboru podle pokynů uvedených na platformě Teams.
