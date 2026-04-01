-- Procedimiento que Carga el Incurridos netos de los Reclamos 
-- en un Periodo Dado
--
-- Creado    : 10/06/2014 - Autor: ANGEL TELLO
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che192;

CREATE PROCEDURE informix.sp_che192() 
  RETURNING integer, char(50);
				   		

DEFINE _cod_agente char(5);
DEFINE _saldo      dec(16,2);
DEFINE _comision   dec(16,2);
DEFINE _estatus_licencia char(1);
DEFINE _auxiliar   char(5); 
DEFINE _agente     VARCHAR(50);
DEFINE _saldo_26410 dec(16,2);
DEFINE _comision2   dec(16,2);
DEFINE _saldo_ant   dec(16,2);
DEFINE _saldo_act   dec(16,2);
DEFINE _no_requis, _no_requis_c   char(10);
DEFINE _fecha_ult_comis DATE;
define _error       integer;
define _error_desc  char(50);

set isolation to dirty read;



FOREACH
	select cod_agente,
	       no_requis,
		   monto
      into _cod_agente,
	       _no_requis,
		   _saldo_26410
	  from chqchmae
	 where origen_cheque in ('2', '7') and fecha_captura = '22/10/2020'

	select a.nombre,
		   a.saldo, 
		   a.estatus_licencia
	  into _agente,
		   _saldo,
		   _estatus_licencia
	  from agtagent a
	 where a.cod_agente = _cod_agente;

	UPDATE chqcomis
	   SET no_requis   = _no_requis
	 WHERE cod_agente  = _cod_agente
	   AND fecha_desde >= '14/10/2020'
	   AND fecha_hasta <= '20/10/2020'
	   AND no_requis is null;
	 
    FOREACH
		 select no_requis
		   into _no_requis_c
		   from chqchmae
		  where cod_agente = _cod_agente
		    and origen_cheque in (2, 7)
			and anulado = 1
			and no_requis is not null
			and no_requis <> _no_requis
	        AND fecha_anulado >= '14/10/2020'
	        AND fecha_anulado <= '20/10/2020'

		 If _no_requis_c is not null And Trim(_no_requis_c) <> "" Then
			 update chqcomis
			    set no_requis = _no_requis
			  where no_requis = _no_requis_c;
		 End If
    END FOREACH
	
 	-- Registros Contables de Cheques de Comisiones

	call sp_par205(_no_requis) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if
  

END FOREACH
	RETURN 0,'Exito';

END PROCEDURE;