-- Procedure que Verifica la Secuencia Numerica de
-- las tablas del Sistema

-- Creado    : 22/02/2002 - Autor: Demetrio Hurtado Almanza
-- Modificado: 22/02/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_para_sp_par53_dw1 - DEIVID, S.A.

drop procedure sp_par53;

create procedure sp_par53(a_periodo char(4)) 
returning char(100),char(20), smallint;

--define a_periodo    char(4);
define _contador	integer;
define _no_recibo	char(20);
define _recibo1		integer;
define _recibo2		integer;
define _diferencia	integer;
define _mensaje		char(100);
define _tipo		char(20);

define _pol_suc		char(2);
define _pol_ram		char(2);
define _pol_ano		char(2);

define _pol_suc_1  	char(2);
define _pol_ram_1	char(2);
define _pol_ano_1  	char(2);

define _validar     char(10);
define _validarNo	char(10);

define _cantidad	integer;
define _valor       char(10);

set isolation to dirty read;
--set debug file to "sp_par53.trc";
--trace on;

-- let a_periodo = "2000";

-- Secuencia Transacciones Reclamos

LET _contador = 0;
LET _tipo     = "Reclamos - Transacciones";

--{
foreach
 select transaccion
   into _no_recibo
   from rectrmae
  where actualizado = 1
    and periodo[1,4] matches a_periodo
  order by 1 asc

	LET _contador = _contador + 1;

	BEGIN 

	ON EXCEPTION IN(-1213)

		LET _mensaje = "La Transaccion de Reclamos #: " || _no_recibo ||
		               " Tiene Formato Incorrecto ...";
		RETURN _mensaje, _tipo, 1 with resume;
		LET _recibo1 = 0;
		CONTINUE FOREACH;

	END EXCEPTION

		IF _contador = 1 THEN
			LET _recibo1 = _no_recibo[4,10];
		END IF				

		LET _recibo2 = _no_recibo[4,10];

	END

	IF _recibo1 <> _recibo2 THEN

		LET _diferencia = _recibo2 - _recibo1;
		IF _diferencia <> 1 THEN
			LET _mensaje = "La Transaccion de Reclamos #: " || _recibo1 + 1 ||
			               " No ha sido Capturado ...";
			RETURN _mensaje, _tipo, 2 with resume;
		END IF
		LET _recibo1 = _no_recibo[4,10];

	END IF

end foreach
--}

-- Transacciones Reclamos Duplicadas

--{
LET _contador = 0;

foreach
 select transaccion,
        count(*)
   into _no_recibo,
        _contador
   from rectrmae
  where actualizado = 1
    and periodo[1,4] matches a_periodo
  group by 1
  order by 1 asc

	if _contador = 1 then
		continue foreach;
	end if

	LET _mensaje = "El Numero de Transaccion de Reclamo #: " || _no_recibo ||
	               " Esta Duplicado " || _contador || " Veces ... ";
	RETURN _mensaje, _tipo, 3 with resume;

end foreach
--}

LET _contador = 0;
LET _tipo     = "Reclamos - Emision";

-- Reclamos Duplicados
--{
foreach
 select numrecla,
        count(*)
   into _no_recibo,
        _contador
   from recrcmae
  where actualizado = 1
    and periodo[1,4] matches a_periodo
  group by 1
  order by 1 asc

	if _contador = 1 then
		continue foreach;
	end if

	LET _mensaje = "El Numero de Reclamo #: " || _no_recibo ||
	               " Esta Duplicado " || _contador || " Veces ... ";
	RETURN _mensaje, _tipo, 1 with resume;

end foreach
--}

-- Secuencia de Reclamos

--{
let _pol_ram_1 = "xx";
let _pol_ano_1 = "xx";
LET _contador  = 0;
LET _recibo1   = 0;
LET _recibo2   = 0;

foreach
 select numrecla,
		numrecla[1,2],
		numrecla[6,7]
   into _no_recibo,
		_pol_ram,
		_pol_ano
   from recrcmae
  where actualizado = 1
	and periodo[1,4] matches a_periodo
  order by 2, 3, 1

	if _pol_ram = _pol_ram_1 and
	   _pol_ano = _pol_ano_1 then
	else
		LET _contador  = 0;
		let _pol_ram_1 = _pol_ram;
		let _pol_ano_1 = _pol_ano;
	end if	

	LET _contador = _contador + 1;

	BEGIN 

	ON EXCEPTION IN(-1213)

		LET _mensaje = "EL Reclamo #: " || _no_recibo ||
		               " Tiene Formato Incorrecto ...";
		RETURN _mensaje, _tipo, 2 with resume;

	END EXCEPTION

		IF _contador = 1 THEN
			LET _recibo1 = _no_recibo[9,13];
		END IF				

		LET _recibo2 = _no_recibo[9,13];

	END

	BEGIN 

	ON EXCEPTION IN(-1213)

	END EXCEPTION

		IF _recibo1 <> _recibo2 THEN

			LET _diferencia = _recibo2 - _recibo1;
			IF _diferencia <> 1 THEN
				LET _mensaje = "Ramo " || _pol_ram || "   " ||
				               "Periodo " || _pol_ano || "   " || 
				               "EL Reclamo #: " || _recibo1 + 1 || "   " ||
				               "No ha sido Capturado ...";
				RETURN _mensaje, _tipo, 3 with resume;
			END IF
			LET _recibo1 = _no_recibo[9,13];

		END IF

	END

end foreach
--}

--{
-- Facturas Duplicadas

LET _contador = 0;
LET _tipo     = "Facturas";

foreach
 select no_factura,
        count(*)
   into _no_recibo,
        _contador
   from endedmae
  where actualizado = 1
    and periodo[1,4] matches a_periodo
  group by 1
  order by 1 asc

	if _contador = 1 then
		continue foreach;
	end if

	LET _mensaje = "La Factura #: " || _no_recibo ||
	               " Esta Duplicada " || _contador || " Veces ... ";
	RETURN _mensaje, _tipo, 1 with resume;

end foreach
--}

--{
-- Secuencia para Facturas

LET _contador = 1;

foreach
 select no_factura
   into _no_recibo
   from endedmae
  where actualizado = 1
    and periodo[1,4] matches a_periodo
  order by 1 asc

	BEGIN 

	ON EXCEPTION IN(-1213)

		LET _mensaje = "La Factura #: " || _no_recibo ||
		               " Tiene Formato Incorrecto ...";
		RETURN _mensaje, _tipo, 3 with resume;

	END EXCEPTION

		IF _contador = 1 THEN
			LET _recibo1  = _no_recibo[4,10];
			LET _contador = 0;
		END IF				

		LET _recibo2 = _no_recibo[4,10];

	END

	IF _recibo1 <> _recibo2 THEN

		LET _diferencia = _recibo2 - _recibo1;

		IF _diferencia <> 1 THEN


			LET _validarNO = _no_recibo[1,3] ||	_recibo1 + 1;

			SELECT no_factura
			  INTO _validar
			  FROM endedmae
			 WHERE no_factura = _validarNO;

			IF _validar IS NULL THEN
				LET _mensaje = "Sucursal " || _no_recibo[1,2] || " La Factura #: " || _recibo1 + 1 || 
				               " No ha sido Capturada ...";
				RETURN _mensaje, _tipo, 2 with resume;
			END IF

		END IF

		LET _recibo1 = _no_recibo[4,10];

	END IF

end foreach
--}

-- Secuencia de Polizas
--{
let _pol_suc_1 = "xx";
let _pol_ram_1 = "xx";
let _pol_ano_1 = "xx";
LET _tipo      = "Polizas";
LET _contador  = 0;
LET _recibo1   = 0;
LET _recibo2   = 0;

foreach
 select no_documento,
		no_documento[12,13],
		no_documento[1,2],
		no_documento[3,4]
   into _no_recibo,
		_pol_suc,
		_pol_ram,
		_pol_ano
   from emipomae
  where nueva_renov = "N"
    and actualizado = 1
	and periodo[1,4] matches a_periodo
  order by 2, 3, 4, 1

	if _pol_suc = _pol_suc_1 and
	   _pol_ram = _pol_ram_1 and
	   _pol_ano = _pol_ano_1 then
	else
		LET _contador  = 0;
		let _pol_suc_1 = _pol_suc;
		let _pol_ram_1 = _pol_ram;
		let _pol_ano_1 = _pol_ano;

	end if	

	LET _contador = _contador + 1;

	BEGIN 

	ON EXCEPTION IN(-1213)

		LET _mensaje = "La Poliza #: " || _no_recibo ||
		               " Tiene Formato Incorrecto ...";
		RETURN _mensaje, _tipo, 2 with resume;

	END EXCEPTION

		IF _contador = 1 THEN
			LET _recibo1 = _no_recibo[6,10];
		END IF				

		LET _recibo2 = _no_recibo[6,10];

	END

	BEGIN 

	ON EXCEPTION IN(-1213)

	END EXCEPTION

		IF _recibo1 <> _recibo2 THEN

			LET _diferencia = _recibo2 - _recibo1;
			IF _diferencia <> 1 THEN
				LET _mensaje = "Sucursal " || _pol_suc || "   " ||
				               "Ramo " || _pol_ram || "   " ||
				               "Periodo " || _pol_ano || "   " || 
				               "La Poliza #: " || _recibo1 + 1 || "   " ||
				               "No ha sido Capturada ...";
				RETURN _mensaje, _tipo, 1 with resume;
			END IF
			LET _recibo1 = _no_recibo[6,10];

		END IF

	END

end foreach
--}

-- Polizas Duplicadas
--{
foreach
 select no_documento,
        count(*)
   into _no_recibo,
        _contador
   from emipomae
  where actualizado = 1
    and nueva_renov = "N"
    and periodo[1,4] matches a_periodo
  group by 1
  order by 1 asc

	if _contador = 1 then
		continue foreach;
	end if

	LET _mensaje = "La Poliza #: " || _no_recibo ||
	               " Esta Duplicada " || _contador || " Veces ... ";
	RETURN _mensaje, _tipo, 1 with resume;

end foreach
--}

-- Secuencia para Recibos
--{
LET _contador = 0;
LET _tipo     = "Recibos";

FOREACH
 SELECT	d.no_recibo
   INTO	_no_recibo
   FROM	cobremae m, cobredet d
  WHERE m.no_remesa   = d.no_remesa
	AND d.renglon    <> 0 
	AND d.actualizado = 1
	AND m.tipo_remesa IN ("A", "M")
	AND m.periodo[1,4] matches a_periodo
  GROUP BY no_recibo 
  ORDER BY no_recibo ASC

	LET _contador = _contador + 1;

	BEGIN 

	ON EXCEPTION IN(-1213)

		LET _mensaje = "El Recibo #: " || _no_recibo ||
		               " Tiene Formato Incorrecto ...";
		RETURN _mensaje, _tipo, 2 with resume;

	END EXCEPTION

		IF _contador = 1 THEN
			LET _recibo1 = _no_recibo;
		END IF				

		LET _recibo2 = _no_recibo;

	END

	IF _recibo1 <> _recibo2 THEN

		LET _diferencia = _recibo2 - _recibo1;

		IF _diferencia <> 1 THEN

			let _valor = _recibo1 + 1;

			select count(*)
			  into _cantidad
			  from cobredet
			 where no_recibo = _valor;
			 
			if _cantidad = 0 then			 			

				LET _mensaje = "El Recibo #: " || _recibo1 + 1 ||
				               " No ha sido Capturado ...";
				RETURN _mensaje, _tipo, 1 with resume;

			end if

		END IF

		LET _recibo1 = _no_recibo;

	END IF

END FOREACH
--}

end procedure
