-- Proceso que verifica si hay diferencia del impuesto entre endedmae y endeduni
-- Creado    : 08/08/2012 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro365;

create procedure sp_pro365(a_no_poliza char(10),a_no_endoso char(5))
returning integer,
		  integer,
          char(100);

define _no_unidad			char(5);
define _prima_ajustada_uni	dec(16,2);
define _prima_ajustada_emi	dec(16,2);
define _imp_ajustado_emi	dec(16,2);
define _imp_ajustado_uni	dec(16,2);
define _prima_bruta_emi		dec(16,2);
define _prima_bruta_uni		dec(16,2);
define _imp_emipouni		dec(16,2);
define _imp_endeduni		dec(16,2);
define _imp_endedmae		dec(16,2);
define _unidad_imp			dec(16,2);
define _dif_imp				dec(16,2);
define _ajuste				dec(16,2);
define _cant_iter			smallint;
define _cont				smallint;

let _no_unidad			= '00000';
let _prima_bruta_uni	= 0.00;
let _imp_endeduni		= 0.00;
let	_imp_endedmae		= 0.00;
let	_unidad_imp			= 0.00;
let	_dif_imp			= 0.00;
let _ajuste				= 0.00;
let _cant_iter			= 0;
let _cont				= 0;

--set debug file to "sp_pro365.trc";
--trace on;

select sum(impuesto)
  into _imp_endeduni
  from endeduni
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

select impuesto
  into _imp_endedmae
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

let _dif_imp	= (_imp_endeduni - _imp_endedmae);

if _dif_imp > 0 then
	let _ajuste = -0.01;
else
	let _ajuste = 0.01;
end if

let _cant_iter	= abs(_dif_imp)	* 100 ;

if _dif_imp <> 0.00 then
	foreach
		select no_unidad
		  into _no_unidad
		  from endeduni
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso
		 order by no_unidad

		select impuesto,
			   prima_bruta	
		  into _unidad_imp,
			   _prima_bruta_uni	
		  from endeduni
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso
		   and no_unidad = _no_unidad;
		
		select prima_bruta,
			   impuesto
		  into _prima_bruta_emi,
			   _imp_emipouni
		  from emipouni
		 where no_poliza = a_no_poliza
		   and no_unidad = _no_unidad;		 

		if _cont >= _cant_iter then
			exit foreach;
		end if
		
		if _unidad_imp > 0 then
			let _imp_ajustado_uni	= _unidad_imp + _ajuste;
			let _prima_ajustada_uni	= _prima_bruta_uni + _ajuste;
		else
			continue foreach;
		end if
		
		update endeduni
		   set impuesto		= _imp_ajustado_uni,
		   	   prima_bruta	= _prima_ajustada_uni 	 	
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso
		   and no_unidad = _no_unidad;

		if _imp_emipouni > 0 then
			let _imp_ajustado_emi	= _imp_emipouni + _ajuste;
			let _prima_ajustada_emi	= _prima_bruta_emi + _ajuste;
		else
			continue foreach;
		end if

		update emipouni
		   set impuesto		= _imp_ajustado_emi,
		   	   prima_bruta	= _prima_ajustada_emi 	 	
		 where no_poliza = a_no_poliza
		   and no_unidad = _no_unidad;
		   
		let _cont = _cont + 1;		
	end foreach
end if

return 0,0,'';
end procedure