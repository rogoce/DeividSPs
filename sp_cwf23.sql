-- Creacion de la Transaccion Inicial de Reclamos
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_cwf23;
CREATE PROCEDURE "informix".sp_cwf23(a_no_requis char(10), a_sucursal char(3))
returning varchar(25);

define _monto			dec(16,2);
define _monto_rec		dec(16,2);
define _monto_tr		dec(16,2);
define _ld_lim_max		dec(16,2);
define _dominio_ultimus	varchar(20);
define _cod_asignacion  char(10);
define _user_added      char(10);
define _codigo_perfil   char(3);

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
 
select user_added
  into _user_added
  from rectrmae
 where no_tranrec = a_no_requis;
 
select codigo_perfil
  into _codigo_perfil
  from insuser
 where usuario = _user_added; 

--IF a_sucursal = "010" THEN	--UAP
--	select valor_parametro
--	  into v_grupo
--	  from inspaag
--	 where codigo_compania  = '001'
--	   and codigo_agencia   = '010'
--		and aplicacion       = 'REC'
--		and version          = '02'
--		and codigo_parametro = "supervisor_uap";

-- Por instrucciones se excluye al supervisor uap para la aprobacion de transacciones de reservas de la uap -- Sra Margarita y Wilson -- 06-01-2025
-- Se hará en la tabla inspaag de seguridad
IF _codigo_perfil = "177" THEN --UAP
	select valor_parametro
	  into v_grupo
	  from inspaag
	 where codigo_compania  = '001'
	   and codigo_agencia   = '001'
		and aplicacion       = 'REC'
		and version          = '02'
		and codigo_parametro = "supervisor_uap";
ELSE
	select valor_parametro
	  into v_grupo
	  from inspaag
	 where codigo_compania  = '001'
	   and codigo_agencia   = '001'
		and aplicacion       = 'REC'
		and version          = '02'
		and codigo_parametro = "supervisor";

    foreach
        select cod_asignacion
		  into _cod_asignacion
		  from rectrmae
		 where no_tranrec = a_no_requis	--> este campo desde workflow es no_tranrec

        exit foreach;
    end foreach 

    if _cod_asignacion is not null and _cod_asignacion <> ""  then
        set lock mode to wait;

        update atcdocde
		   set suspenso = 1
		 where cod_asignacion = _cod_asignacion
		   and completado     = 0;

		SET ISOLATION TO DIRTY READ;
	end if

END IF

LET v_grupo = TRIM(_dominio_ultimus) || trim(v_grupo);

return trim(v_grupo);	
END
end procedure
