-- Actualizadion masiva de los datos de promotorias

-- Creado    : 04/09/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 04/09/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par244;

create procedure "informix".sp_par244()
returning integer;

define _ret_desc		char(100);
define _ret_valor		smallint;
define _cod_agente 		char(5);
define _cod_vendedor	char(3);
define _cod_ramo 		char(3);

-- Oficina Salud

update parpromo
   set cod_vendedor = "028"
 where cod_agencia  in ("001", "004")
   and cod_ramo     in ("004", "016", "018", "019")
   and cod_vendedor <> "030";

-- Raul

update parpromo
   set cod_vendedor = "027"
 where cod_agencia  in ("001", "004")
   and cod_ramo     in ("004", "016", "018", "019")
   and cod_vendedor <> "030"
   and cod_agente   in ("00705", 
                        "01266", 
                        "00235",
						"00822",
						"00892",
						"01100",
						"00008",
						"00244",
						"00250",
						"00978",
						"00335",
						"00621",
						"00956",
						"01241",
						"00649",
						"00161",
						"00525",
						"00779",
						"00259",
						"00540",
						"00628",
						"00975",
						"01009",
						"00124",
						"00125",
						"00214",
						"00264",
						"00731",
						"00636",
						"00732",
						"00865",
						"00180",
						"01090",
						"00798",
						"01081",
						"00741",
						"00257",
						"00924",
						"00741",
						"01077",
						"01063",
						"01014",
						"01148",
						"00562",
						"01108",
						"00787",
						"00106",
						"01253");

-- Yahir

update parpromo
   set cod_vendedor = "038"
 where cod_agencia  in ("001", "004")
   and cod_ramo     in ("004", "016", "018", "019")
   and cod_vendedor <> "030"
   and cod_agente   in ("00035",
						"00547",
						"00166",
						"00517",
						"00474",
						"01018",
						"00006",
						"00974",
						"00623",
						"01048",
						"01048",
						"00189",
						"00473",
						"01139",
						"01130",
						"00050",
						"00845",
						"01129",
						"00221",
						"00034",
						"00255",
						"00088",
						"00849",
						"00883",
						"01385",
						"01360",
						"01173",
						"01383",
						"00158"
						);

-- Fabiola

update parpromo
   set cod_vendedor = "023"
 where cod_agencia  in ("001", "004")
   and cod_ramo     in ("004", "016", "018", "019")
   and cod_vendedor <> "030"
   and cod_agente   in ("00992",
						"00620",
						"00026",
						"00037",
						"01365",
						"00609",
						"00412",
						"01248",
						"00133",
						"00218",
						"00119",
						"00398",
						"01369",
						"01400",
						"01368",
						"01387",
						"01408",
						"01006",
						"00948",
						"01021",
						"00470",
						"01110",
						"00140",
						"00889",
						"01419",
						"01413",
						"01414"
						);

return 0;
  
end procedure;


























