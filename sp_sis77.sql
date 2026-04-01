-- Informacion necesaria para que Luis Martinez haga el calculo del aumento de primas

-- Creado    : 03/06/2005 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sis77;

create procedure "informix".sp_sis77()
returning smallint,
          char(7),
		  char(3),
		  smallint,
		  smallint,
		  dec(16,2);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _cod_cliente		char(10);
define _fecha_nac		date;
define _edad			smallint;
define _periodo			char(7);
define _fecha_calc		date;
define _cant_aseg		integer;
define _cant_rec		integer;
define _incurrido		dec(16,2);
define _monto			dec(16,2);
define _variacion		dec(16,2);
define _cod_tipotran	char(3);
define _cod_subramo		char(3);
define _no_unidad		char(5);

create temp table tmp_edad(
edad		smallint,
periodo		char(7),
cod_subramo	char(3),
cant_aseg	integer,
cant_rec	integer,
incurrido	dec(16,2)
) with no log;

set isolation to dirty read;

foreach
 select e.no_poliza,
        e.no_endoso,
        e.periodo,
		p.cod_subramo
   into _no_poliza,
        _no_endoso,
        _periodo,
		_cod_subramo
   from emipomae p, endedmae e
  where p.no_poliza   = e.no_poliza
    and e.actualizado = 1
	and p.cod_ramo    = "018"
    and e.periodo     >= "2003-01"
    and e.periodo     <= "2005-05"
	and p.cod_subramo in ("007", "008")
	and e.cod_endomov in ("011", "014")

	let _fecha_calc = sp_sis36(_periodo);

	foreach
	 select cod_cliente,
	        no_unidad
	   into _cod_cliente,
	        _no_unidad
	   from endeduni
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso

		select fecha_aniversario
		  into _fecha_nac
		  from cliclien
		 where cod_cliente = _cod_cliente;

		if _fecha_nac is null then
			let _edad = -1;
		else
			let _edad = sp_sis78(_fecha_nac, _fecha_calc);
		end if

		if _edad < -1 then
			let _edad = -1;
		end if

		if _edad > 100 then
			let _edad = -1;
		end if

		insert into tmp_edad
		values (_edad, _periodo, _cod_subramo, 1, 0, 0); 

		foreach
		 select cod_cliente
		   into _cod_cliente
		   from emidepen
		  where no_poliza = _no_poliza
		    and no_unidad = _no_unidad

			select fecha_aniversario
			  into _fecha_nac
			  from cliclien
			 where cod_cliente = _cod_cliente;

			if _fecha_nac is null then
				let _edad = -1;
			else
				let _edad = sp_sis78(_fecha_nac, _fecha_calc);
			end if

			if _edad < -1 then
				let _edad = -1;
			end if

			if _edad > 100 then
				let _edad = -1;
			end if

			insert into tmp_edad
			values (_edad, _periodo, _cod_subramo, 1, 0, 0); 

		end foreach

	end foreach

end foreach

foreach
 select	r.cod_reclamante,
        r.periodo,
        p.cod_subramo 
   into	_cod_cliente,
        _periodo,
        _cod_subramo			 
   from recrcmae r, emipomae p
  where	r.no_poliza   = p.no_poliza
    and p.cod_ramo    = "018"
    and r.periodo     >= "2003-01"
	and	r.periodo     <= "2005-05"
	and p.cod_subramo in ("007", "008")
    and r.actualizado = 1
  
	select fecha_aniversario
	  into _fecha_nac
	  from cliclien
	 where cod_cliente = _cod_cliente;

	if _fecha_nac is null then
		let _edad = -1;
	else
		let _fecha_calc = sp_sis36(_periodo);
		let _edad       = sp_sis78(_fecha_nac, _fecha_calc);
	end if

	if _edad < -1 then
		let _edad = -1;
	end if

	if _edad > 100 then
		let _edad = -1;
	end if

	insert into tmp_edad
	values (_edad, _periodo, _cod_subramo, 0, 1, 0); 

end foreach

-- Incurrido
 
foreach
 select	r.cod_reclamante,
        t.periodo,
        t.monto,
        t.variacion,
        t.cod_tipotran,
        p.cod_subramo 
   into	_cod_cliente,
        _periodo,
        _monto,
        _variacion,
        _cod_tipotran,
        _cod_subramo			 
   from recrcmae r, emipomae p, rectrmae t
  where	r.no_poliza   = p.no_poliza
    and r.no_reclamo  = t.no_reclamo
    and p.cod_ramo    = "018"
    and t.periodo     >= "2003-01"
	and	t.periodo     <= "2005-05"
	and p.cod_subramo in ("007", "008")
    and t.actualizado = 1
  
	select fecha_aniversario
	  into _fecha_nac
	  from cliclien
	 where cod_cliente = _cod_cliente;

	if _fecha_nac is null then
		let _edad = -1;
	else
		let _fecha_calc = sp_sis36(_periodo);
		let _edad       = sp_sis78(_fecha_nac, _fecha_calc);
	end if

	if _edad < -1 then
		let _edad = -1;
	end if

	if _edad > 100 then
		let _edad = 1000;
	end if

	if _cod_tipotran in ("004") then
		let _incurrido = _monto + _variacion;
	elif _cod_tipotran in ("005", "006", "007") then
		let _incurrido = _monto;
	else
		let _incurrido = _variacion;
	end if

	insert into tmp_edad
	values (_edad, _periodo, _cod_subramo, 0, 0, _incurrido); 

end foreach

foreach
 select edad,
        periodo,
		cod_subramo,
		sum(cant_aseg),
		sum(cant_rec),
		sum(incurrido)
   into _edad,
        _periodo,
		_cod_subramo,
		_cant_aseg,
		_cant_rec,
		_incurrido
   from tmp_edad
  group by 3, 1, 2
  order by 3, 1, 2

	return _edad,
	       _periodo,
		   _cod_subramo,
		   _cant_aseg,
		   _cant_rec,
		   _incurrido
		   with resume;

end foreach

drop table tmp_edad;

end procedure
