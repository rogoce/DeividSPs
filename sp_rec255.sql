-- drop procedure sp_rec255;

create procedure "informix".sp_rec255(a_reclamo char(10)) 
returning  dec(16,2);  -- Incurrido Bruto

define _monto_tran     	dec(16,2);
define _incurrido_bruto  	dec(16,2);
define v_porc_coas	   		dec(7,4);
					   

let	v_porc_coas = null;

foreach
 select porc_partic_coas
   into v_porc_coas
   from reccoas r, parparam p
  where r.cod_coasegur 	= p.par_ase_lider
    and r.no_reclamo 		= a_reclamo
end foreach

if v_porc_coas is null then
   let v_porc_coas = 0;
end if

let _incurrido_bruto   = 0.00;

foreach
 select monto
   into _monto_tran
   from rectrmae
  where no_reclamo   = a_reclamo
    and actualizado  = 1
    and cod_tipotran in ("004", "005", "006", "007")

	let _monto_tran       	= _monto_tran * v_porc_coas / 100;
	let _incurrido_bruto	= _incurrido_bruto + _monto_tran;

end foreach

foreach
 select variacion
   into _monto_tran
   from rectrmae
  where no_reclamo   = a_reclamo
    and actualizado  = 1
    and variacion    <> 0.00

	let _monto_tran      	= _monto_tran * v_porc_coas / 100;
	let _incurrido_bruto	= _incurrido_bruto + _monto_tran;

end foreach

return _incurrido_bruto;

end procedure