drop procedure sp_pro165;

create procedure "informix".sp_pro165(a_periodo char(7))
returning char(50),
          char(7),
		  integer,
		  integer,
		  integer,
		  integer,
		  dec(16,2),
		  integer,
		  dec(16,2),
		  integer,
		  char(15);

define _no_poliza		char(10);
define _no_documento	char(20);
define _cod_ramo		char(3);
define _cod_subramo 	char(3);
define _nombre_sub		char(50);
define _nueva_renov		char(1);

define _cant_uni		integer;
define _cant_pol_vig	integer;
define _cant_pol_nue	integer;
define _cant_dep_vig	integer;
define _cant_dep_nue	integer;
define _prima_suscrita	dec(16,2);
define _cant_reclamos	integer;
define _incurrido_bruto	dec(16,2);

define _periodo			char(7);
define _periodo1		char(7);
define _periodo2		char(7);
define _no_reclamo		char(10);
define _porc_coas		dec(16,4);

define _cod_cliente		char(10);
define _fecha_nac		date;
define _edad			integer;
define _tipo_susc		integer;
define _tipo_susc_desc	char(15);
define _cod_producto	char(5);

set isolation to dirty read;

let _periodo1 = "2003-01";
let _periodo2 = a_periodo;

create temp table tmp_salud(
	subramo			char(50),
	periodo			char(7),
	edad			integer,
	tipo_susc_desc	char(15),
	cant_pol_vig	integer   default 0,
	cant_pol_nue	integer   default 0,
	cant_dep_vig	integer   default 0,
	cant_dep_nue	integer   default 0,
	prima_suscrita	dec(16,2) default 0.00,
	cant_reclamos	integer   default 0,
	incurrido_bruto	dec(16,2) default 0.00
	) with no log;

foreach
 select	no_poliza,
        no_documento,
        cod_ramo,
        cod_subramo,
		nueva_renov,
		periodo
   into	_no_poliza,
        _no_documento,
        _cod_ramo,
        _cod_subramo,
		_nueva_renov,
		_periodo
   from emipomae
  where cod_ramo    = "018"
    and cod_subramo in ("007","008")
    and actualizado = 1
--and no_documento = "1801-00132-01"
	
	select count(*)
	  into _cant_uni
	  from emipouni
	 where no_poliza = _no_poliza;

	if _cant_uni > 1 then
		continue foreach;
	end if

	select cod_asegurado,
	       cod_producto
	  into _cod_cliente,
	       _cod_producto
	  from emipouni
	 where no_poliza = _no_poliza;

	select tipo_suscripcion
	  into _tipo_susc
	  from prdprod
	 where cod_producto = _cod_producto;

	if _tipo_susc = 1 then
		let _tipo_susc_desc = "SOLO";
	elif _tipo_susc = 2 then
		let _tipo_susc_desc = "1 DEPENDIENTE";
	elif _tipo_susc = 3 then
		let _tipo_susc_desc = "FAMILIA";
	else
		let _tipo_susc_desc = "BLANCO";
	end if

	select fecha_aniversario
	  into _fecha_nac
	  from cliclien
	 where cod_cliente = _cod_cliente;

	let _edad = sp_sis78(_fecha_nac, today);

	select nombre
	  into _nombre_sub
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	-- Cantidad de polizas nuevas

	if _nueva_renov = "N" then
		let _cant_pol_nue = 1;
	else
		let _cant_pol_nue = 0;
	end if

	insert into tmp_salud(subramo, periodo, edad, tipo_susc_desc, cant_pol_nue)
	values (_nombre_sub, _periodo, _edad, _tipo_susc_desc, _cant_pol_nue);

	-- Cantidad de polizas vigentes

	foreach
	 select periodo,
	        cant_pol_vig
	   into _periodo,
	        _cant_pol_vig
	   from deivid_bo:emipolvi
	  where no_documento = _no_documento
	    and periodo      >= _periodo1
	    and periodo      <= _periodo2

		insert into tmp_salud(subramo, periodo, edad, tipo_susc_desc, cant_pol_vig)
		values (_nombre_sub, _periodo, _edad, _tipo_susc_desc, _cant_pol_vig);

	end foreach

	-- Cantidad de Dependientes Nuevos

	if _nueva_renov = "N" then

		select count(*)
		  into _cant_dep_nue
		  from emidepen
		 where no_poliza = _no_poliza;

	else

		let _cant_dep_nue = 0;

	end if

	insert into tmp_salud(subramo, periodo, edad, tipo_susc_desc, cant_dep_nue)
	values (_nombre_sub, _periodo, _edad, _tipo_susc_desc, _cant_dep_nue);

	-- Cantidad de Dependientes Vigentes

	select count(*)
	  into _cant_dep_vig
	  from emidepen
	 where no_poliza = _no_poliza;

	insert into tmp_salud(subramo, periodo, edad, tipo_susc_desc, cant_dep_vig)
	values (_nombre_sub, _periodo, _edad, _tipo_susc_desc, _cant_dep_vig);

	-- Prima Suscrita

   foreach	
	select periodo,
	       prima_suscrita
	  into _periodo,
	       _prima_suscrita
	  from endedmae
	 where no_poliza   = _no_poliza
	   and actualizado = 1
	   and periodo     >= _periodo1
	   and periodo     <= _periodo2

		insert into tmp_salud(subramo, periodo, edad, tipo_susc_desc, prima_suscrita)
		values (_nombre_sub, _periodo, _edad, _tipo_susc_desc, _prima_suscrita);

	end foreach

	-- Cantidad de Reclamos

   foreach
	select periodo
	  into _periodo
	  from recrcmae
	 where no_poliza   = _no_poliza
	   and periodo     >= _periodo1
	   and periodo     <= _periodo2
	   and actualizado = 1

		insert into tmp_salud(subramo, periodo, edad, tipo_susc_desc, cant_reclamos)
		values (_nombre_sub, _periodo, _edad, _tipo_susc_desc, 1);

	end foreach	

	-- Pagos, Salvamentos, Recuperos y Deducibles

	FOREACH
	 SELECT t.periodo,
			t.monto,
			t.no_reclamo
	   INTO _periodo,
	   		_incurrido_bruto,
			_no_reclamo
	   FROM rectrmae t, recrcmae r 
	  WHERE t.no_reclamo   = r.no_reclamo
	    and r.no_poliza    = _no_poliza
	    AND t.actualizado  = 1
		AND t.cod_tipotran IN ('004','005','006','007')
		AND t.periodo      >= _periodo1 
		AND t.periodo      <= _periodo2
	    AND t.monto        <> 0

		-- Informacion de Coseguro

		SELECT porc_partic_coas
		  INTO _porc_coas
	      FROM reccoas
	     WHERE no_reclamo   = _no_reclamo
	       AND cod_coasegur = "036";

		IF _porc_coas IS NULL THEN
			LET _porc_coas = 0;
		END IF

		-- Calculos

		LET _incurrido_bruto = _incurrido_bruto / 100 * _porc_coas;

		insert into tmp_salud(subramo, periodo, edad, tipo_susc_desc, incurrido_bruto)
		values (_nombre_sub, _periodo, _edad, _tipo_susc_desc, _incurrido_bruto);

	END FOREACH

	-- Variacion de Reserva

	FOREACH
	 SELECT t.periodo,
			t.variacion,
			t.no_reclamo
	   INTO _periodo,
	   		_incurrido_bruto,
			_no_reclamo
	   FROM rectrmae t, recrcmae r 
	  WHERE t.no_reclamo   = r.no_reclamo
	    and r.no_poliza    = _no_poliza
	    AND t.actualizado  = 1
		AND t.periodo      >= _periodo1 
		AND t.periodo      <= _periodo2
	    AND t.variacion    <> 0

		-- Informacion de Coseguro

		SELECT porc_partic_coas
		  INTO _porc_coas
	      FROM reccoas
	     WHERE no_reclamo   = _no_reclamo
	       AND cod_coasegur = "036";

		IF _porc_coas IS NULL THEN
			LET _porc_coas = 0;
		END IF

		-- Calculos

		LET _incurrido_bruto = _incurrido_bruto / 100 * _porc_coas;

		insert into tmp_salud(subramo, periodo, edad, tipo_susc_desc, incurrido_bruto)
		values (_nombre_sub, _periodo, _edad, _tipo_susc_desc, _incurrido_bruto);

	END FOREACH

end foreach

foreach
 select subramo,			
		periodo,
		edad,
		tipo_susc_desc,
		sum(cant_pol_vig),	
		sum(cant_pol_nue),	
		sum(cant_dep_vig),	
		sum(cant_dep_nue),	
		sum(prima_suscrita),	
		sum(cant_reclamos),	
		sum(incurrido_bruto)
   into	_nombre_sub,			
		_periodo,
		_edad,			
		_tipo_susc_desc,
		_cant_pol_vig,	
		_cant_pol_nue,	
		_cant_dep_vig,	
		_cant_dep_nue,	
		_prima_suscrita,	
		_cant_reclamos,	
		_incurrido_bruto
   from tmp_salud
  where periodo >= _periodo1
    and periodo <= _periodo2
  group by 1, 2, 3, 4
  order by 1, 2, 3, 4

	return _nombre_sub,	
		   _periodo,		
		   _cant_pol_vig,	
		   _cant_pol_nue,	
		   _cant_dep_vig,	
		   _cant_dep_nue,	
		   _prima_suscrita,
		   _cant_reclamos,	
		   _incurrido_bruto,
		   _edad,
		   _tipo_susc_desc
		   with resume;
		
end foreach

drop table tmp_salud;

end procedure




















