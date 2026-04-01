-- Prodecimiento que arregla la facturacion de salud del 2003 que se realizo incorrecta

drop procedure sp_par72;

create procedure sp_par72()
returning char(100);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_unidad 		char(5);
define _prima			dec(16,2);
define _suma			dec(16,2);
define _cod_tipoprod	char(3);
define _porc_coas       dec(7,4);
define _cantidad		integer;
define _descripcion     char(100);

begin work;

let _cantidad = 0;

foreach
 select no_poliza,
        no_endoso
   into	_no_poliza,
        _no_endoso
   from endedmae
  where actualizado = 1
    and periodo     = "2003-01"
	and cod_endomov = "014"

	let _cantidad = _cantidad + 1;

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
     where no_poliza = _no_poliza;

	if _cod_tipoprod = "001" then

		SELECT porc_partic_coas
		  INTO _porc_coas
		  FROM emicoama
		 WHERE no_poliza    = _no_poliza
		   AND cod_coasegur = "036";

		IF _porc_coas IS NULL THEN
			LET _porc_coas = 100;
		END IF

	ELSE
		LET _porc_coas = 100;
	END IF


	delete from emifacon
	 where no_poliza         = _no_poliza
	   and no_endoso         = _no_endoso
	   and porc_partic_prima = 0.00
	   and porc_partic_suma  = 0.00
	   and cod_contrato      in ("00512", "00523", "00521");
	   
	delete from emireaco
	 where no_poliza         = _no_poliza
	   and porc_partic_prima = 0.00
	   and porc_partic_suma  = 0.00
	   and cod_contrato      in ("00512", "00523", "00521");


	foreach
	 select no_unidad,
	        prima_neta,
			suma_asegurada
	   into _no_unidad,
	        _prima,
			_suma
	   from endeduni
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso

		let _prima = _prima / 100 * _porc_coas;
		let _suma  = _suma  / 100 * _porc_coas;

		--let _descripcion = _no_poliza || " " || _no_unidad || " " || _prima || " " || _suma;
		--return _descripcion with resume;

		update endeduni
		   set prima_suscrita    = _prima,
		       prima_retenida    = _prima
		 where no_poliza         = _no_poliza
		   and no_endoso         = _no_endoso
		   and no_unidad         = _no_unidad;

		update emifacon
		   set porc_partic_prima = 100,
		       porc_partic_suma  = 100,
			   prima 			 = _prima,
			   suma_asegurada    = _suma
		 where no_poliza         = _no_poliza
		   and no_endoso         = _no_endoso
		   and no_unidad         = _no_unidad;
		   
		update emireaco
		   set porc_partic_prima = 100,
		       porc_partic_suma  = 100
		 where no_poliza         = _no_poliza
		   and no_unidad         = _no_unidad;

	end foreach

	select sum(prima_suscrita),
	       sum(suma_asegurada)
	  into _prima,
	       _suma
	  from endeduni
     where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _prima is null then
		let _prima = 0;
	end if

	if _suma is null then
		let _suma = 0;
	end if

	update endedmae
	   set prima_suscrita    = _prima,
	       prima_retenida    = _prima,
		   suma_asegurada	 = _suma
	 where no_poliza         = _no_poliza
	   and no_endoso         = _no_endoso;

end foreach

--rollback work;
commit work;

return "Fueron Procesados " || _cantidad || " Registros";

end procedure;
























							  