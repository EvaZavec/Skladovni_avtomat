type stanje = Stanje.t
type sklad = Sklad.t

type t = {
  stanja : stanje list;
  zacetno_stanje : stanje;
  sprejemna_stanja : stanje list;
  prehodi : (stanje * char * char option * stanje * (sklad -> sklad)) list;
}

let prazen_avtomat zacetno_stanje =
  {
    stanja = [ zacetno_stanje ];
    zacetno_stanje;
    sprejemna_stanja = [];
    prehodi = [];
  }

let dodaj_nesprejemno_stanje stanje avtomat =
  { avtomat with stanja = stanje :: avtomat.stanja }

let dodaj_sprejemno_stanje stanje avtomat =
  {
    avtomat with
    stanja = stanje :: avtomat.stanja;
    sprejemna_stanja = stanje :: avtomat.sprejemna_stanja;
  }

let dodaj_prehod stanje1 znak vrh_sklada stanje2 spremeni_sklad avtomat =
  { avtomat with prehodi = (stanje1, znak, vrh_sklada, stanje2, spremeni_sklad) :: avtomat.prehodi }

let prehodna_funkcija avtomat stanje znak sklad =
  let vrh_sklada = Sklad.na_vrhu_sklada sklad in
  match
    List.find_opt
      (fun (stanje1, znak', vrh_sklada', _, _) -> stanje1 = stanje && znak = znak' && vrh_sklada' = vrh_sklada)
      avtomat.prehodi
  with
  | None -> None
  | Some (_, _, _, stanje2, spremeni_sklad) -> Some (stanje2, spremeni_sklad sklad)

let zacetno_stanje avtomat = avtomat.zacetno_stanje
let seznam_stanj avtomat = avtomat.stanja
let seznam_prehodov avtomat = avtomat.prehodi

let je_sprejemno_stanje avtomat stanje =
  List.mem stanje avtomat.sprejemna_stanja

let gnezdenje_oklepajev =
  let zacetno = Stanje.iz_niza "Zacetno"
  and sprejemno = Stanje.iz_niza "Sprejemno" 
  and napaka = Stanje.iz_niza "Napaka" in
  prazen_avtomat zacetno 
  |> dodaj_sprejemno_stanje sprejemno
  |> dodaj_nesprejemno_stanje napaka 

  |> dodaj_prehod zacetno '(' None sprejemno (fun sklad -> Sklad.dodaj_na_sklad '(' sklad)
  |> dodaj_prehod zacetno '{' None sprejemno (fun sklad -> Sklad.dodaj_na_sklad '{' sklad)
  |> dodaj_prehod zacetno '[' None sprejemno (fun sklad -> Sklad.dodaj_na_sklad '[' sklad)
  |> dodaj_prehod zacetno ')' None napaka (fun sklad -> sklad)
  |> dodaj_prehod zacetno '}' None napaka (fun sklad -> sklad)
  |> dodaj_prehod zacetno ']' None napaka (fun sklad -> sklad)

  |> dodaj_prehod sprejemno '(' None sprejemno (fun sklad -> Sklad.dodaj_na_sklad '(' sklad)
  |> dodaj_prehod sprejemno '(' (Some '(') sprejemno (fun sklad -> Sklad.dodaj_na_sklad '(' sklad)
  |> dodaj_prehod sprejemno '(' (Some '{') sprejemno (fun sklad -> Sklad.dodaj_na_sklad '(' sklad)
  |> dodaj_prehod sprejemno '(' (Some '[') sprejemno (fun sklad -> Sklad.dodaj_na_sklad '(' sklad)

  |> dodaj_prehod sprejemno ')' (Some '(') sprejemno Sklad.iz_sklada
  |> dodaj_prehod sprejemno ')' (Some '{') napaka (fun sklad -> sklad)
  |> dodaj_prehod sprejemno ')' (Some '[') napaka (fun sklad -> sklad)
  |> dodaj_prehod sprejemno ')' None napaka (fun sklad -> sklad)

  |> dodaj_prehod sprejemno '{' None sprejemno (fun sklad -> Sklad.dodaj_na_sklad '{' sklad)
  |> dodaj_prehod sprejemno '{' (Some '(') sprejemno (fun sklad -> Sklad.dodaj_na_sklad '{' sklad)
  |> dodaj_prehod sprejemno '{' (Some '{') sprejemno (fun sklad -> Sklad.dodaj_na_sklad '{' sklad)
  |> dodaj_prehod sprejemno '{' (Some '[') sprejemno (fun sklad -> Sklad.dodaj_na_sklad '{' sklad)

  |> dodaj_prehod sprejemno '}' (Some '(') napaka (fun sklad -> sklad)
  |> dodaj_prehod sprejemno '}' (Some '{') sprejemno Sklad.iz_sklada
  |> dodaj_prehod sprejemno '}' (Some '[') napaka (fun sklad -> sklad)
  |> dodaj_prehod sprejemno '}' None napaka (fun sklad -> sklad)

  |> dodaj_prehod sprejemno '[' None sprejemno (fun sklad -> Sklad.dodaj_na_sklad '[' sklad)
  |> dodaj_prehod sprejemno '[' (Some '(') sprejemno (fun sklad -> Sklad.dodaj_na_sklad '[' sklad)
  |> dodaj_prehod sprejemno '[' (Some '{') sprejemno (fun sklad -> Sklad.dodaj_na_sklad '[' sklad)
  |> dodaj_prehod sprejemno '[' (Some '[') sprejemno (fun sklad -> Sklad.dodaj_na_sklad '[' sklad)

  |> dodaj_prehod sprejemno ']' (Some '(') napaka (fun sklad -> sklad)
  |> dodaj_prehod sprejemno ']' (Some '{') napaka (fun sklad -> sklad)
  |> dodaj_prehod sprejemno ']' (Some '[') sprejemno Sklad.iz_sklada
  |> dodaj_prehod sprejemno ']' None napaka (fun sklad -> sklad)

let preberi_niz avtomat q niz =
  let aux acc znak =
    match acc with
    | None -> None
    | Some (q, sklad) -> prehodna_funkcija avtomat q znak sklad
  in
  niz |> String.to_seq |> Seq.fold_left aux (Some (q, Sklad.prazen_sklad))
