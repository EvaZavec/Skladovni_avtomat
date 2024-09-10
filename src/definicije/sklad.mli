type t

val prazen_sklad : t
val dodaj_na_sklad : char -> t -> t
val iz_sklada : t -> t
val sklad_je_prazen : t -> bool
val na_vrhu_sklada : t -> char option
