# Skladovni avtomat za preverjanje gnezdenja oklepajev

Projekt vsebuje implementacijo skladovnega avtomata, ki je razširitev končnega avtomata, saj dodatno uporablja še sklad. Tako kot končni avtomat tudi skladovni avtomat začne v enem izmed možnih stanj, ki ga označimo za začetno, od tam pa prehaja v druga stanja glede na trenutno stanje, trenutni simbol v nizu in pa tudi trenutni simbol na vrhu sklada. Ker je glede na te podatke prehod točno definiran, gre za determinističen avtomat. Ob prehodu v drugo stanje, se lahko spremeni tudi sklad, in sicer lahko dodamo ali pa odvzamemo element na vrhu sklada. Niz je sprejet, če avtomat konča v enem izmed sprejemnih stanj in če je ob koncu sklad prazen.

V našem primeru uporabljamo skladovni avtomat za preverjanje pravilnosti gnezdenja oklepajev v nizu. Sklad je na začetku prazen, potem pa se uporablja za shranjevanje oklepajev, ki se izbrišejo, ko najdemo ustrezen zaklepaj, ki je njegov par. V primeru, da naletimo na zaklepaj, ki ni imel primernega oklepaja, avtomat preide v nesprejemno stanje. Na koncu mora biti stanje sprejemno, sklad pa prazen, ker to pomeni, da smo vsakemu oklepaju našli ustrezen zaklepaj.


## Matematična definicija

Skladovni avtomat je formalno definiran kot $7$-elemntni nabor:

$M = \(Q, \Sigma, \Gamma, \delta, q_0, Z, F\)$, kjer je 

- $Q$ množica stanj,
- $\Sigma$ končna množica, imenovana vhodna abeceda,
- $\Gamma$ končna množica, imenovana abeceda sklada,
- $\delta$ končna podmnožica $Q \times \Sigma \times \Gamma \to Q \times \Gamma^{*}$, prehodna relacija,
- $q_0 \in Q$ začetno stanje,
- $Z \in Γ$ začetni simbol sklada,
- $F \subseteq Q$ množica sprejemnih stanj.

Za naš primer je potreben le $5$-elementni nabor, saj je na začetku sklad prazen, abecedi pa se med seboj ujemata. Elementi nabora so torej
- $Q = \{\text{zacetno, sprejemno, napaka}\}$,
- $\Sigma = \{ (, ), \\{, \\}, [, ] \} = \Gamma$
- $q_0 = \text{zacetno}$,
- $F = \text{sprejemno}$,

in pa $\delta$, ki ima veliko elementov, saj je veliko prehodov. Za začetno stanje privzamemo, da je sklad prazen, zato lahko preide le v sprejemno stanje ali napako, glede na naslednji simbol v nizu. Ko je trenutno stanje avtomata napaka, bo ne glede na nadaljevanje niza in elemente v skladu  ostal v tem stanju, zato ne potrebujemo definirati prehodov. Za sprejemno stanje pa pogledamo vsako kombinacijo simbola v nizu in simbola na vrhu sklada. Ko je trenutni simbol v nizu oklepaj, ga dodamo na sklad in stanja ne spreminjamo. Ko pa je trenutni znak zaklepaj, preverimo, če je na vrhu sklada njegov oklepaj, in v tem primeru ostanemo v sprejemnem stanju ter hkrati iz vrha sklada vzamemo ta oklepaj. Če je na vrhu sklada drug simbol ali pa je sklad prazen, avtomat preide v stanje napaka.


## Navodila za uporabo

Projekt je namenjen preverjanju gnezdenja oklepajev. Za lažjo uporabo je na voljo tekstovni vmesnik, ki po zagonu uporabnika seznani z možnostmi. Uporabnik lahko izpiše stanja avtomata, kjer je označeno začetno stanje in sprejemna stanja. Lahko pa tudi izbere, da bo vnesel niz oklepajev in preveril, ali so oklepaji pravilno gnezdeni. Ko zaključi z uporabo, lahko z izbiro možnosti Izhod iz programa tudi odide. 

Tekstovni vmesnik prevedemo z ukazom `dune build`, ki v korenskem imeniku ustvari datoteko `tekstovniVmesnik.exe`. Za zagon programa pa v konzolo vpišemo še ukaz `dune exec ./tekstovniVmesnik.exe`.

Če OCamla nimate nameščenega, lahko še vedno preizkusite tekstovni vmesnik prek ene od spletnih implementacij OCamla, najbolje <http://ocaml.besson.link/>, ki podpira branje s konzole. V tem primeru si na vrh datoteke `tekstovniVmesnik.ml` dodajte še vrstice

```ocaml
module Avtomat = struct
    (* celotna vsebina datoteke avtomat.ml *)
end
```

## Implementacija

### Struktura datotek

Program ima vse glavne datoteke v mapi `src`. V mapi `definicije` se nahajajo glavne datoteke:
- `avtomat.ml`,
- `sklad.ml`,
- `stanje.ml`,
- `trak.ml`,
- `zagnaniAvtomat.ml`.

Vsaka izmed naštetih datotek ima še ustrezno `.mli` datoteko, v kateri je zapisana signatura glavne datoteke. Datoteki `trak.ml` in `zagnaniAvtomat.ml` s svojima signaturama za tako preprosto implementacijo tekstovnega vmesnika nista nujno potrebni, vendar sem ju ohranila, saj omogočata nadgradnjo in razvoj tudi spletnega vmesnika.

V drugi mapi `tekstovniVmesnik`, se nahaja le ena datoteka in sicer `tekstovniVmesnik.ml`, ki implementira tekstovni vmesnik za interakcijo z avtomatom.

### `avtomat.ml`

V datoteki so definirani tip avtomata, prazen avtomat in funkcije za dodajanje sprejemnih stanj, nesprejemnih stanj in prehodov. S prehodno funkcijo poiščemo prehod, ki ustreza trenutnemu stanju avtomata, trenutnemu simbolu in vrhu sklada. V datoteki so implementirane tudi funkcije, ki nam izpišejo začetno stanje, seznam vseh stanj in seznam vseh prehodov, pa tudi funkcija, ki preveri če je stanje eno izmed sprejemnih. 
Vse te funkcije so zbrane v dveh glavnih funkcijah: `gnezdenje_oklepajev`, ki ustvari tri stanja za naš avtomat in doda prehode med njimi, 

in `preberi_niz`, ki se s pomočjo prehodne funkcije sprehodi čez niz in pomika po ustreznih stanjih, vrne pa stanje in sklad ob zaključku kot `option`.

### `sklad.ml`

V tej datoteki je definiran tip sklad in vse ključne funkcije za delo z njim. To so funkcije, ki element dodajo na vrh sklada oziroma ga vzamejo iz vrha ter funkcija, ki vrne vrh sklada, ne da bi sklad spremenila. Implementiran pa je tudi prazen sklad in funkcija, ki preverja, če je sklad prazen.

### `stanje.ml`

Definiramo tip stanje in funkciji, ki iz niza naredi stanje ter obratno.

### `trak.ml`

Datoteka implementira tip traku, po katerem se lahko sprehajamo s funkcijo `premakni_naprej`. Definirane so funkcije, ki ugotovijo trenutni znak, vse že prebrane znake ter vse še neprebrane znake v nizu. Datoteka vsebuje tudi funkcijo za prazen niz in funkcijo, ki preveri, če je trak na koncu, ter funkciji za pretvarjanje med trakom in nizom.

### `zagnaniAvtomat.ml`

Tukaj je definiran tip zagnanega avtomata, ki ga poženemo tako, da stanje nastavimo na začetno stanje in sklad na prazen sklad. S funkcijo `korak_naprej` se lahko sprehodimo čez cel trak do konca, kjer s funkcijo `je_v_sprejemnem_stanju` preverimo, ali je končno stanje sprejemno.

Ta datoteka in datoteka `trak.ml`, bi prišli v uporabo pri implementaciji spletnega vmesnika.

### `tekstovniVmesnik.ml`

Datoteka uporabi vse prej definirane funkcije, da ustvarimo tektovni vmesnik, ki uporabniku omogoča vpis niza oklepajev in preverjanje, če so oklepaji gnezdeni pravilno. 

Tekstovni vmesnik se lahko nahaja v $6$ različnih stanjih, med katerimi prehajamo s pomočjo sporočila `ZamenjajVmesnik` in funkcije `view`, ki za vsako stanje določa, kaj se zgodi:
- `SeznamMoznosti`: Izpišejo se možnosti, ki jih ima uporabnik, in sicer izpis avtomata, vnos niza in izhod. 
- `IzpisAvtomata`: Vmesnik preide v to stanje, če je uporabnik izbral, da želi izpisati avtomat. S pomočjo funkcije `izpisi_avtomat` se izpišejo stanja avtomata, kjer je začetno stanje označeno s '->', sprejemna stanja pa s '+'. Ko se avtomat izpiše, vmesnik spet preide v stanje `SeznamMoznosti`.
- `BranjeNiza`: Preberemo niz in s pomočjo sporočila `PreberiNiz` preidemo bodisi v stanje `OpozoriloONapacnem` nizu, ce je niz neustrezen, bodisi v stanje `RezultatNiza`.
- `RezultatPrebranegaNiza`: Izpiše se, ali ima niz pravilno gnezdene oklepaje ali ne, nato pa se vmesnik vrne v stanje `SeznamMoznosti`.
- `OpozoriloONapacnemNizu`: V to stanje pridemo, če je uporabnik vpisal niz, ki ni bil zgolj iz oklepajev, zato uporabnika opozorimo na napako in mu damo ponovno možnost za vnos niza s prehodom na stanje BranjeNiza.
- `Izhod`: Vmesnik se nahaja v tem stanju, če je uporabnik izbral možnost izhod. V tem primeru se od njega poslovimo in zaključimo s programom. 

