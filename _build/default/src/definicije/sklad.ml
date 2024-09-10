type t = char list

let prazen_sklad = []

let dodaj_na_sklad el sklad = el :: sklad

let iz_sklada sklad =
  match sklad with
  | [] -> []
  | _ :: rep -> rep

let sklad_je_prazen sklad =
  sklad = []

let na_vrhu_sklada sklad =
  match sklad with
  | [] -> None
  | el :: _ -> Some el
