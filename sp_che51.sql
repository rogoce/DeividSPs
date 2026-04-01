-- -- Creado    : 22/11/2000 - Autor: Amado Perez 
-- Modificado: 11/12/2000 - Autor: Armando Moreno

-- SIS v.2.0 - d_cheq_sp_che08_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_che51;

CREATE PROCEDURE sp_che51()
RETURNING date,date,DEC(16,2),integer,integer;

DEFINE _monto       	DEC(16,2);
DEFINE _monto_acum     	DEC(16,2);
DEFINE _no_requis   	CHAR(10);
DEFINE _numrecla	   	CHAR(18);
DEFINE _saber       	SMALLINT;
define i,j				integer;
define _fecha			date;
define _fecha2			date;
define _tope			integer;
define _cant			integer;
define _mes				integer;
		
SET ISOLATION TO DIRTY READ;

let _monto_acum = 0;
let _cant       = 0;
let _mes        = 0;

CREATE TEMP TABLE tmp_tabla(
	fecha		    date,
	tope	        integer
	) WITH NO LOG;

CREATE TEMP TABLE tmp_tabla1(
	fecha		    date,
	fecha2          date,
	monto			dec(16,2),
	cantidad		integer
	) WITH NO LOG;

for i = 1 to 4
	if i = 1 then
		let _fecha = "02/01/2006";
		let _tope  = 4;
	elif i = 2 then
		let _fecha = "06/02/2006";
		let _tope  = 3;
	elif i = 3 then
		let _fecha = "06/03/2006";
		let _tope  = 3;
	else
		let _fecha = "03/04/2006";
		let _tope  = 4;
	end if

	INSERT INTO tmp_tabla(
	  fecha,
	  tope
	  )
	  VALUES(
	  _fecha,
	  _tope
	  );
end for

FOREACH

 select fecha,
        tope
   into _fecha,
        _tope
   from tmp_tabla
  order by fecha

 let _fecha2 = _fecha + 5;

 for j = 1 to _tope
	foreach

		 SELECT	monto,
		        no_requis
		   INTO	_monto,
		        _no_requis
		   FROM	chqchmae
		  WHERE fecha_impresion >= _fecha
		    and fecha_impresion <= _fecha2
			AND pagado           = 1
			and anulado          = 0

		 if _no_requis is not null then
			 SELECT	count(*)
			   INTO	_saber
		   	   FROM	rectrmae
			  WHERE no_requis = _no_requis;

			 if _saber > 0 then
			   foreach
				 SELECT	numrecla
				   INTO	_numrecla
			   	   FROM	rectrmae
				  WHERE no_requis = _no_requis

				 if _numrecla[1,2] = "18" then
					let _monto_acum = _monto_acum + _monto;
					let _cant = _cant + 1;
					exit foreach;
				 end if
			   end foreach
			 end if

		 else
			continue foreach;
		 end if

	end foreach

		INSERT INTO tmp_tabla1(
		fecha,
		fecha2,
		monto,
		cantidad
		)
		VALUES(
		_fecha,
		_fecha2,
		_monto_acum,
		_cant
		);

		let _fecha  	= _fecha2 + 2;
		let _fecha2 	= _fecha  + 5;
		let _monto_acum = 0;
		let _cant		= 0;
end for

END FOREACH

foreach
	select fecha,
		   fecha2,
		   monto,
		   cantidad,
		   month(fecha)
	  into _fecha,
	       _fecha2,
		   _monto,
		   _cant,
		   _mes
	  from tmp_tabla1
	  order by fecha

	RETURN  _fecha,
			_fecha2,
			_monto,
			_cant,
			_mes     
			WITH RESUME;

end foreach

drop table tmp_tabla;
drop table tmp_tabla1;

END PROCEDURE;