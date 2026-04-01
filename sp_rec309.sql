-- Procedure que actualiza la requisiciones cuando hay excepcion

-- AmadoPerez 10/01/2017


drop procedure sp_rec309;

create procedure sp_rec309(a_requis char(10), a_finiquito smallint default 0, a_usuario char(8) default null)
RETURNING integer, varchar(100);

define _error_cod		integer;
define _error_isam		integer;
define _error_desc		varchar(100);

define _transaccion     char(10);
define _no_reclamo      char(10);
define _no_poliza       char(10);
define _cod_ramo        char(3);
define _ramo_sis        smallint;
define _cod_tipopago    char(3);
define _cnt             smallint;
define _no_tranrec      char(10);

set isolation to dirty read;
--SET LOCK MODE TO WAIT;

begin
on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_desc;
end exception

let _error_cod = 0;
let _cnt       = 0;

FOREACH
	select transaccion
	  into _transaccion
	  from chqchrec
	 where no_requis = a_requis
	 
	select no_tranrec,
	       no_reclamo,
	       cod_tipopago
	  into _no_tranrec,
	       _no_reclamo,
	       _cod_tipopago
	  from rectrmae
	 where transaccion = _transaccion;
	
	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo =_no_reclamo;
	 
	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;
	
    -- Queda pendiente patrimoniales y fianzas	
	if _ramo_sis = 1 then 	-- Automovil
		-- Buscando si tien los concepto son 015 PAGO DIRECTO ASEG. o 044 REEMBOLSO AL ASEGURADO debe tener firmado el finiquito
		select count(*)
		  into _cnt
		  from rectrcon a
		 where a.no_tranrec = _no_tranrec
		   and a.cod_concepto in ('015','044');
		   
		if _cnt is null then
			let _cnt = 0;
		end if
	
		if _cod_tipopago = '003' and a_finiquito = 0 and _cnt > 0 then
			let _error_cod = 1;
			exit foreach;
			--return 0, "No es pago a asegurado";
		end if
	elif _ramo_sis in (5, 7) then -- Personas
		if _cod_tipopago = '004' and a_finiquito = 0 then
			let _error_cod = 1;
			exit foreach;
			--return 0, "No es pago a tercero";
		end if
		--return 0, "Aun no se implementa";
	else
	  --  return 0, "Este ramo no genera finiquito";
	end if

END FOREACH

if _error_cod <> 0 then
	return _error_cod, "Verifique finiquito requisicion " || a_requis;
end if

update chqchmae 
	set aut_imp_tec = 1,
	    finiquito_firmado = a_finiquito,
		user_aut_imp_tec = a_usuario,
		date_aut_imp_tec = current
 where no_requis = a_requis;

				  
RETURN 0, "Actualizacion Exitosa";

end
end procedure