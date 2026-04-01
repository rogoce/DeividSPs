-- Procedure que Verifica la Secuencia Numerica de Recibos

-- Creado    : 22/02/2002 - Autor: Demetrio Hurtado Almanza
-- Modificado: 22/02/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_para_sp_par94_dw1 - DEIVID, S.A.

drop procedure sp_par94;

create procedure sp_par94(a_ano char(4)) 
returning char(100),
		  char(20), 
		  smallint,
		  integer;

define _contador	integer;
define _mensaje		char(100);
define _tipo		char(20);

define _cantidad	integer;
define _valor       char(10);
define _valor1      char(10);
define _valor2      char(10);
define _impreso     smallint;
define _primera		integer;

define a_recibos_desde	integer;
define a_recibos_hasta	integer;

define _desde	char(10);
define _hasta	char(10);

set isolation to dirty read;

--set debug file to "sp_par94.trc";
--trace on;

-- Secuencia para Recibos

LET _impreso  = 0;
LET _contador = 0;
LET _primera  = 0;
let _valor1   = "";
let _valor2   = "";

LET _tipo     = "Recibos";

select min(d.no_recibo),
       max(d.no_recibo)
  into _desde,
	   _hasta
  from cobredet d, cobremae m
 where d.no_remesa     = m.no_remesa
   and d.periodo[1,4]  = a_ano
   and d.actualizado   = 1
   and d.renglon       <> 0
   and m.tipo_remesa   in ("A", "M");

let a_recibos_desde = _desde;
let a_recibos_hasta = _hasta;
 
for _contador = a_recibos_desde to a_recibos_hasta

	let _valor   = _contador;

	select count(*)
	  into _cantidad
	  from cobredet
	 where no_recibo = _valor;

	if _cantidad = 0 then			 			

		let _primera = _primera + 1;
		let _impreso = 0;

		if _primera = 1 then		
			let _valor1  = _contador;
		end if

		let _valor2  = _contador;

	else
		
		if _impreso = 0 then

			let _impreso = 1;
			LET _primera = 0;

			if _valor1 <> _valor2 then

				LET _mensaje = "Recibos Desde " || _valor2 || " Hasta " || _valor1 || " No han sido Capturados ...";
				RETURN _mensaje, _tipo, 1, _contador with resume;

			else

				LET _mensaje = "Recibo Numero " || _valor1 || " No ha sido Capturado ...";
				RETURN _mensaje, _tipo, 1, _contador with resume;

			end if

		end if

	end if

end for


if _impreso = 0 then

	let _impreso = 1;
	LET _primera = 0;

	if _valor1 <> _valor2 then

		LET _mensaje = "Recibos Desde " || _valor2 || " Hasta " || _valor1 || " No han sido Capturados ...";
		RETURN _mensaje, _tipo, 1, _contador with resume;

	else

		LET _mensaje = "Recibo Numero " || _valor1 || " No ha sido Capturado ...";
		RETURN _mensaje, _tipo, 1, _contador with resume;

	end if

end if

{
FOREACH
 SELECT	d.no_recibo
   INTO	_no_recibo
   FROM	cobremae m, cobredet d
  WHERE m.no_remesa   = d.no_remesa
	AND d.renglon    <> 0 
	AND d.actualizado = 1
	AND m.tipo_remesa IN ("A", "M")
--	AND m.periodo[1,4] >= "2002"
  GROUP BY no_recibo 
  ORDER BY no_recibo ASC

	LET _contador = _contador + 1;

	BEGIN 

	ON EXCEPTION IN(-1213)

		LET _mensaje = "El Recibo #: " || _no_recibo ||
		               " Tiene Formato Incorrecto ...";
--		RETURN _mensaje, _tipo, 2 with resume;

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
				RETURN _mensaje, _tipo, 1, _recibo1 + 1 with resume;

			end if

		END IF

		LET _recibo1 = _no_recibo;

	END IF

END FOREACH
}

end procedure
