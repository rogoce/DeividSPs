DROP procedure sp_amm14c;

CREATE procedure "informix".sp_amm14c()
returning integer;

DEFINE li_dia		   SMALLINT;
DEFINE li_mes		   SMALLINT;
DEFINE li_ano		   SMALLINT;
DEFINE ld_fecha_1_pago DATE;
define _vi		   	   date;
DEFINE li_no_pagos	   SMALLINT;
DEFINE ls_cod_perpago  CHAR(3);
DEFINE li_meses		   SMALLINT;
define _no_poliza      char(10);
define _cant		   integer;

SET ISOLATION TO DIRTY READ;

let _cant = 0;

FOREACH
 SELECT vigencia_inic,
        no_poliza,
		no_pagos,
		cod_perpago
   INTO _vi,
        _no_poliza,
		li_no_pagos,
		ls_cod_perpago
   FROM emipomae
  where actualizado = 1
    and nueva_renov = "R"
	and fecha_primer_pago < vigencia_inic
--	and user_added = "JAQUELIN"
--	and no_poliza = "182310"

if li_no_pagos = 1 then

	let ld_fecha_1_pago = _vi;

	select meses
	  into li_meses
	  from cobperpa
	 where cod_perpago = ls_cod_perpago;

	let li_mes = month(ld_fecha_1_pago) + li_meses;
	let li_ano = year(ld_fecha_1_pago);
	let li_dia = day(ld_fecha_1_pago);

	If li_mes > 12 Then
		let li_mes = li_mes - 12;
		let li_ano = li_ano + 1;
	End If

	If li_mes = 2 Then
		If li_dia > 28 Then
			let li_dia = 28;
		End If
	Elif li_mes in (4, 6, 9, 11) Then
		If li_dia > 30 Then
			let li_dia = 30;
		End If
	End If

	let ld_fecha_1_pago = MDY(li_mes, li_dia, li_ano);

	let _vi = ld_fecha_1_pago;

end if

   UPDATE emipomae
     SET fecha_primer_pago = _vi
   WHERE no_poliza = _no_poliza;

   UPDATE endedmae
     SET fecha_primer_pago = _vi
   WHERE no_poliza = _no_poliza
     and no_endoso = "00000";

	let _cant = _cant + 1;

END FOREACH

return _cant;
END PROCEDURE