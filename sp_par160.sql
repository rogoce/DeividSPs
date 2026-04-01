-- Creacion de la tabla (prdnewpro) para las nuevas tarifas de salud

-- Creado    : 29/07/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par160;

create procedure "informix".sp_par160()

define _tipo_suscripcion	smallint;
define _cod_producto		char(5);
define _cod_producto_new	char(5);

-- Plan Panama

foreach
 select cod_producto,
        tipo_suscripcion
   into _cod_producto,
        _tipo_suscripcion
   from prdprod
  where cod_producto in ("00143",
"00168",
"00169",
"00171",
"00172",
"00173",
"00186",
"00210",
"00211",
"00212",
"00229",
"00233",
"00236",
"00237",
"00238",
"00240",
"00241",
"00245",
"00246",
"00247",
"00250",
"00251",
"00252",
"00374",
"00379",
"00380",
"00381",
"00468"
)

	if _tipo_suscripcion = 1 then
		let _cod_producto_new = "00494";
	elif _tipo_suscripcion = 2 then
		let _cod_producto_new = "00495";
	elif _tipo_suscripcion = 3 then
		let _cod_producto_new = "00496";
	end if

	insert into prdnewpro
	values (_cod_producto, _cod_producto_new);

end foreach

-- Plan Panama Plus

foreach
 select cod_producto,
        tipo_suscripcion
   into _cod_producto,
        _tipo_suscripcion
   from prdprod
  where cod_producto in ("00142",
"00166",
"00167",
"00194",
"00207",
"00209",
"00215",
"00253",
"00254",
"00255",
"00275",
"00276",
"00347",
"00348",
"00349",
"00358",
"00361",
"00362",
"00364",
"00376",
"00377",
"00378",
"00386",
"00387",
"00388",
"00430",
"00436",
"00480"

)

	if _tipo_suscripcion = 1 then
		let _cod_producto_new = "00497";
	elif _tipo_suscripcion = 2 then
		let _cod_producto_new = "00498";
	elif _tipo_suscripcion = 3 then
		let _cod_producto_new = "00499";
	end if

	insert into prdnewpro
	values (_cod_producto, _cod_producto_new);

end foreach

end procedure