open Definicije
open Avtomat

type stanje_vmesnika =
  | SeznamMoznosti
  | IzpisAvtomata
  | BranjeNiza
  | RezultatPrebranegaNiza
  | OpozoriloONapacnemNizu
  | Izhod

type model = {
  avtomat : Avtomat.t;
  stanje_avtomata : Stanje.t;
  stanje_sklada : Sklad.t;
  stanje_vmesnika : stanje_vmesnika;
}

type msg =
  | PreberiNiz of string
  | ZamenjajVmesnik of stanje_vmesnika
  | Izhod

let update model = function
  | PreberiNiz str -> (
      if str = "" then
        { model with stanje_vmesnika = OpozoriloONapacnemNizu }
      else
      match Avtomat.preberi_niz model.avtomat model.stanje_avtomata str with
      | None -> { model with stanje_vmesnika = OpozoriloONapacnemNizu }
      | Some (stanje_avtomata, stanje_sklada) ->
          {
            model with
            stanje_avtomata;
            stanje_sklada;
            stanje_vmesnika = RezultatPrebranegaNiza;
          })
  | ZamenjajVmesnik stanje_vmesnika -> { model with stanje_vmesnika }
  | Izhod -> { model with stanje_vmesnika = Izhod }

let rec izpisi_moznosti () =
  print_endline "1) izpiši avtomat";
  print_endline "2) preberi niz";
  print_endline "0) izhod";
  print_string "> ";
  match read_line () with
  | "1" -> ZamenjajVmesnik IzpisAvtomata
  | "2" -> ZamenjajVmesnik BranjeNiza
  | "0" -> Izhod
  | _ ->
      print_endline "** VNESI 1, 2 ALI 0 **";
      izpisi_moznosti ()

let izpisi_avtomat avtomat =
  let izpisi_stanje stanje =
    let prikaz = Stanje.v_niz stanje in
    let prikaz =
      if stanje = Avtomat.zacetno_stanje avtomat then "-> " ^ prikaz else prikaz
    in
    let prikaz =
      if Avtomat.je_sprejemno_stanje avtomat stanje then prikaz ^ " +" else prikaz
    in
    print_endline prikaz
  in
  List.iter izpisi_stanje (Avtomat.seznam_stanj avtomat)

let beri_niz () =
  print_string "Vnesi niz oklepajev > ";
  let str = read_line () in
  PreberiNiz str

let izpisi_rezultat model =
  if Avtomat.je_sprejemno_stanje model.avtomat model.stanje_avtomata && Sklad.sklad_je_prazen model.stanje_sklada then
    print_endline "Oklepaji so gnezdeni pravilno."
  else print_endline "Oklepaji so gnezdeni napačno."

let view model =
  match model.stanje_vmesnika with
  | SeznamMoznosti -> izpisi_moznosti ()
  | IzpisAvtomata ->
      izpisi_avtomat model.avtomat;
      ZamenjajVmesnik SeznamMoznosti
  | BranjeNiza -> beri_niz ()
  | RezultatPrebranegaNiza ->
      izpisi_rezultat model;
      ZamenjajVmesnik SeznamMoznosti
  | OpozoriloONapacnemNizu ->
      print_endline "To ni niz oklepajev! Poskusi še enkrat.";
      ZamenjajVmesnik BranjeNiza
  | Izhod -> Izhod

let init avtomat =
  {
    avtomat;
    stanje_avtomata = Avtomat.zacetno_stanje avtomat;
    stanje_sklada = Sklad.prazen_sklad;
    stanje_vmesnika = SeznamMoznosti;
  }

let rec loop model =
  match view model with
  | Izhod -> print_endline "Hvala in adijo!"
  | msg ->
      let model' = update model msg in
      loop model'

let _ =
  let avtomat = gnezdenje_oklepajev in
  loop (init avtomat)