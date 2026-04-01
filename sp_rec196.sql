-- Transacciones de Pago en Abril
-- 
-- Creado    : 09/05/2012 - Autor: Armando Moreno M.
-- Modificado: 09/05/2012 - Autor: Armando Moreno M.
--

--DROP PROCEDURE sp_rec196;

CREATE PROCEDURE sp_rec196() 
RETURNING CHAR(18),
          CHAR(10),
		  DECIMAL(16,2),
          CHAR(10),
		  SMALLINT;    


DEFINE v_filtros          CHAR(255);
DEFINE _transaccion       CHAR(10);
DEFINE _no_requis         CHAR(10);
DEFINE _numrecla          CHAR(18);
DEFINE _reserva_ini_abr   SMALLINT;
DEFINE _monto		      DECIMAL(16,2);
DEFINE _cnt				  smallint;

SET ISOLATION TO DIRTY READ;


FOREACH

	select monto,transaccion,numrecla,no_requis
	  into _monto,_transaccion,_numrecla,_no_requis
	  from rectrmae
	 where actualizado = 1
	   and cod_tipotran = '004'
	   and no_requis is not null
	   and periodo = '2012-04'
	   and numrecla[1,2] in('02','20')
	  order by numrecla

	let _reserva_ini_abr = 0;

	select count(*) --Reserva Inicial de abril
	  into _cnt
	  from rectrmae
	 where numrecla = _numrecla
	   and cod_tipotran = '001'
	   and periodo = '2012-04'
	   and actualizado = 1;

	if _cnt > 0 then
		let _reserva_ini_abr = 1;
	end if


	RETURN _numrecla,
	       _transaccion,
		   _monto,
		   _no_requis,
		   _reserva_ini_abr
		   WITH RESUME;


END FOREACH

END PROCEDURE;
