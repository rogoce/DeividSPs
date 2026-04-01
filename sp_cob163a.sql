--Procedimiento para actualizar fecha de remesa con valor del periodo cuando la fecha de la remesa difiere al periodo.

--Creado    : 26/04/2006 - Autor: Armando Moreno
--Modificado: 26/04/2006 - Autor: Armando Moreno

--SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob163a;

CREATE PROCEDURE "informix".sp_cob163a(a_mes integer,a_ano integer)

define _no_remesa char(10);
define _fecha 	  date;
define _periodo   char(7);
define _dia       char(2);
define _mes       integer;
define _fecha_ok   date;

{foreach

	select no_remesa,
		   fecha,
		   periodo
	  into _no_remesa,
	       _fecha,
		   _periodo
	  from cobremae
	 where actualizado  = 1
	   and month(fecha) <> periodo[6,7]
	   and month(fecha) = a_mes
	   and year(fecha)  = a_ano
	   order by 1

	let _dia = day(_fecha);

	LET _mes = 	_periodo[6,7];

	IF _mes = 2 THEN
	   if _dia > 28 then
		   LET _dia = '28';
	   end if
	ELIF _mes = 4  OR	-- Verificaciones para Abril
		 _mes = 6  OR	-- Verificaciones para Junio
		 _mes = 9  OR	-- Verificaciones para Septiembre-- Primas Suscritas
		 _mes = 11 THEN	-- Verificaciones para Noviembre
	   if _dia > 30 then
		   LET _dia = '30';
	   end if
	END IF

	LET _fecha_ok = MDY(_periodo[6,7],_dia,_periodo[1,4]);

	update cobrepag
	   set fecha = _fecha_ok
	 where no_remesa = _no_remesa;

	update cobredet
	   set fecha = _fecha_ok
	 where no_remesa = _no_remesa;

	update cobremae
	   set fecha = _fecha_ok
	 where no_remesa = _no_remesa;

end foreach}
foreach

	select no_remesa,
		   fecha,
		   periodo
	  into _no_remesa,
	       _fecha,
		   _periodo
	  from cobremae
	 where actualizado  = 1
	   and month(fecha) <> periodo[6,7]
	   and periodo[6,7] = '03'
	   and periodo[1,4] = '2006'
	   order by 1

	let _dia = day(_fecha);

	LET _mes = 	_periodo[6,7];

	IF _mes = 2 THEN
	   if _dia > 28 then
		   LET _dia = '28';
	   end if
	ELIF _mes = 4  OR	-- Verificaciones para Abril
		 _mes = 6  OR	-- Verificaciones para Junio
		 _mes = 9  OR	-- Verificaciones para Septiembre-- Primas Suscritas
		 _mes = 11 THEN	-- Verificaciones para Noviembre
	   if _dia > 30 then
		   LET _dia = '30';
	   end if
	END IF

	LET _fecha_ok = MDY(_periodo[6,7],_dia,_periodo[1,4]);

	update cobrepag
	   set fecha = _fecha_ok
	 where no_remesa = _no_remesa;

	update cobredet
	   set fecha = _fecha_ok
	 where no_remesa = _no_remesa;

	update cobremae
	   set fecha = _fecha_ok
	 where no_remesa = _no_remesa;

end foreach

END PROCEDURE;
