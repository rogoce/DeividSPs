-- Creacion de la Transaccion Inicial de Reclamos
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_cwf13;
CREATE PROCEDURE "informix".sp_cwf13(a_no_requis char(10), a_sucursal char(3))
returning varchar(25);

define _monto			dec(16,2);
define _monto_rec		dec(16,2);
define _monto_tr		dec(16,2);
define _ld_lim_max		dec(16,2);
define _dominio_ultimus	varchar(20);

define v_grupo			varchar(25);
--define _error			char(25);

--SET DEBUG FILE TO "sp_cwf3.trc"; 
--trACE ON;
SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION 
 	RETURN 'ERROR';         
END EXCEPTION           

select dominio_ultimus
  into _dominio_ultimus
  from parparam
 where cod_compania = '001';

LET _monto_tr  = sp_rwf33(a_no_requis);
LET _monto_rec = sp_rwf34(a_no_requis);

LET _monto = _monto_rec + _monto_tr;

IF _monto < 0 THEN
	LET _monto = _monto * -1;
END IF

{select valor_parametro
  into _ld_lim_max
  from inspaag
 where codigo_compania  = '001'
   and codigo_agencia   = '001'
	and aplicacion       = 'REC'
	and version          = '02'
	and codigo_parametro = "lim_max_suc";


{IF _monto > _ld_lim_max THEN
	select valor_parametro
	  into v_grupo
	  from inspaag
	 where codigo_compania  = '001'
	   and codigo_agencia   = '001'
		and aplicacion       = 'REC'
		and version          = '02'
		and codigo_parametro = "jefe_recl_cm";
ELSE }

--se cambia para que solo funcione chiriqui hasta segunda orden. Armando 14/10/09

 {	IF a_sucursal <> "001" THEN
		select username
		  into v_grupo
		  from wf_paramautoriza
		 where firma = 1
		   and frontoffice = 0
		   and sucursal = a_sucursal;

    	IF v_grupo IS NULL THEN
			select valor_parametro
			  into v_grupo
			  from inspaag
			 where codigo_compania  = '001'
			   and codigo_agencia   = '001'
				and aplicacion       = 'REC'
				and version          = '02'
				and codigo_parametro = "jefe_recl_cm";
		END IF
	ELSE
		select valor_parametro
		  into v_grupo
		  from inspaag
		 where codigo_compania  = '001'
		   and codigo_agencia   = '001'
			and aplicacion       = 'REC'
			and version          = '02'
			and codigo_parametro = "jefe_recl_cm";
	END IF}
	IF a_sucursal = "003" THEN	--chiriqui
		select username
		  into v_grupo
		  from wf_paramautoriza
		 where firma = 1
		   and frontoffice = 0
		   and sucursal = a_sucursal;

    	IF v_grupo IS NULL THEN
			select valor_parametro
			  into v_grupo
			  from inspaag
			 where codigo_compania  = '001'
			   and codigo_agencia   = '001'
				and aplicacion       = 'REC'
				and version          = '02'
				and codigo_parametro = "jefe_recl_cm";
		END IF
	ELSE
		select valor_parametro
		  into v_grupo
		  from inspaag
		 where codigo_compania  = '001'
		   and codigo_agencia   = '001'
			and aplicacion       = 'REC'
			and version          = '02'
			and codigo_parametro = "jefe_recl_cm";
	END IF
--END IF

LET v_grupo = TRIM(_dominio_ultimus) || trim(v_grupo);

return trim(v_grupo);	
END
end procedure