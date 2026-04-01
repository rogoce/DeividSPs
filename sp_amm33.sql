-- Procedimiento para los Totales de la Emision de Reclamo
-- 
-- Creado    : 06/11/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 06/11/2000 - Autor: Amado Perez Mendoza
-- Modificado: 03/12/2001 - Autor: Armando Moreno Montenegro.(sacar pagado y deducible(se agrego esta columna al datawindow)
-- de transacciones, arreglar Deducible Pagado y calcular los incurridos desde aqui y no desde el datawindow.
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_amm33;
CREATE PROCEDURE sp_amm33()
			RETURNING  char(10),
					   char(20),
					   char(7);

DEFINE _reserva_actual	 DEC(16,2);
DEFINE _no_tranrec,_no_reclamo       CHAR(10);
DEFINE _numrecla         CHAR(18);
DEFINE _periodo          char(7);
define _variacion        dec(16,2);
define _cod_cobertura    char(5);
	
let _numrecla = null;
let _variacion = 0.00;
let _reserva_actual = 0.00;

FOREACH	
	SELECT no_reclamo,
	       numrecla,
		   periodo
	  INTO _no_reclamo,
	       _numrecla,
		   _periodo
	  FROM recrcmae
	 WHERE actualizado  = 1
	   AND periodo[1,4] = '2022'
	   and numrecla[1,2] <> '18'

	select sum(variacion)
	  into _variacion
	  from rectrmae
	 where no_reclamo  = _no_reclamo
	   and actualizado = 1;

	if _variacion = 0 then
		foreach
			select cod_cobertura,
				   sum(reserva_actual)
			  into _cod_cobertura,
				   _reserva_actual
			  from recrccob
			 where no_reclamo = _no_reclamo
			 group by cod_cobertura
			 
			if _reserva_actual <> 0 then
				return _no_reclamo,_numrecla,_periodo with resume;
				exit foreach;
			end if
		end foreach
	end if
end foreach
END PROCEDURE