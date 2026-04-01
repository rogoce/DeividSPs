-- Procedure para el cambio de tarifas por el cambio de edad

-- Creado    : 27/07/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - d_prod_sp_pro154_dw1 - DEIVID, S.A.

drop procedure sp_par161;
create procedure sp_par161()
returning integer;

define _cantidad		smallint;
define _no_poliza		char(10);
define _fecha_nac	  	date;
define _edad		  	smallint;
define _cod_cliente		char(10);
define _cant_call		smallint;

set isolation to dirty read;

foreach
 SELECT no_poliza
   INTO _no_poliza
   FROM emipomae
  WHERE cod_ramo       = "018"
    AND estatus_poliza = 1 -- Vigentes
    AND actualizado    = 1 -- Actualizado
	and cod_tipoprod   in ("001", "005")

	select count(*)
	  into _cantidad
	  from emipouni
	 where no_poliza = _no_poliza;

	if _cantidad > 1 then
		continue foreach;
	end if

	foreach
	 select cod_asegurado
	   into _cod_cliente
	   from emipouni
	  where no_poliza = _no_poliza

		select fecha_aniversario
		  into _fecha_nac
		  from cliclien
		 where cod_cliente = _cod_cliente;
		 
		let _edad = sp_sis78(_fecha_nac, today);
			
		if _edad is not null then
			continue foreach;
		end if

		select count(*)
		  into _cant_call
		  from clienc01
		 where codigo = _cod_cliente;
		 
		if _cant_call <> 0 then
			continue foreach;
		end if

		execute procedure sp_par166(_cod_cliente);

		return _cod_cliente with resume;		   

	end foreach

end foreach

foreach
 select cod_reclamante
   into _cod_cliente
   from recrcmae
  where periodo[1,4] in ("2004", "2005")
    and numrecla[1,2] = "02"
    and actualizado = 1
  group by cod_reclamante

	select fecha_aniversario
	  into _fecha_nac
	  from cliclien
	 where cod_cliente = _cod_cliente;
	 
	let _edad = sp_sis78(_fecha_nac, today);
		
	if _edad is not null then
		continue foreach;
	end if

	select count(*)
	  into _cant_call
	  from clienc02
	 where codigo = _cod_cliente;
	 
	if _cant_call <> 0 then
		continue foreach;
	end if

	execute procedure sp_par166(_cod_cliente);

	return _cod_cliente with resume;		   

end foreach

return 0;

end procedure
