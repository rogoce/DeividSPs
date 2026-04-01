-- Procedimiento que Verifica los Valores de las Polizas

-- Creado    : 11/06/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 04/04/2002 - Autor: Amado Perez
-- Modificado: 30/08/2002 Mi cumpleaños - se condiciona que cuando sea coaseguro mayoritario
                                       -- pregunte si la diferencia de primas es mayor de 0.20 cts
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sis25bk;			

CREATE PROCEDURE sp_sis25bk(
a_no_poliza		CHAR(10)
) RETURNING SMALLINT,
		    CHAR(100);

DEFINE _prima_neta      DEC(16,2);
DEFINE _prima			DEC(16,2);
DEFINE _prima_sus_sum	DEC(16,2);

DEFINE _error			SMALLINT;
DEFINE _mensaje         CHAR(100);
DEFINE _no_unidad		CHAR(5);

SET ISOLATION TO DIRTY READ;

LET _prima_sus_sum = 0.00;
let _prima_neta    = 0.00;
BEGIN

ON EXCEPTION SET _error 
 	RETURN _error, 'Error al Verificar Informacion de la Poliza ...';         
END EXCEPTION           

-- Sumatoria de la Distribucion de Reaseguro
foreach

select no_unidad,
	   sum(prima)
  INTO _no_unidad,
	   _prima_sus_sum
  from emirerea
 where no_poliza = "179550"
 group by 1
 order by 1

select sum(prima_neta_o)
  INTO _prima_neta
  from emireau2
 where no_poliza = "179550"
   and chek_o = 1
   and no_unidad = _no_unidad;

let _prima = 0.00;
let _prima = abs(_prima_neta - _prima_sus_sum);

IF abs(_prima - _prima_sus_sum) = 0 THEN
else
	select prima
	  INTO _prima_sus_sum
	  from emirerea
	 where no_poliza = "179550"
       and orden = 1
	   and no_unidad = _no_unidad;

	let _prima = _prima_sus_sum - 0.01;

	update emirerea
	   set prima = _prima
     where no_poliza = "179550"
       and orden = 1
	   and no_unidad = _no_unidad;

end if
end foreach


LET _mensaje = 'Verificacion Exitosa ...';
RETURN 0, _mensaje;

END

END PROCEDURE;

