-- Verificacion de las cancelaciones administrativas
-- dado el Numero de Documento

-- Creado    : 02/03/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 02/03/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par184a;
CREATE PROCEDURE sp_par184a()
RETURNING CHAR(20),dec(16,2),char(10);

define _saldo,_saldo1   dec(16,2);
define _no_documento    char(20);
define _no_poliza       char(10);

SET ISOLATION TO DIRTY READ;

FOREACH

	select no_documento,
	       sum(saldo)
	  into _no_documento,
	       _saldo1
	  from emipomae
	 where no_documento in(
						select poliza from deivid_tmp:temp_venc2023may
						where cancelada = 1)
	   and saldo <> 0
	 group by 1
	 --having abs(sum(saldo)) > 1.00
	 order by 1
	let _no_poliza = sp_sis21(_no_documento);
	let _saldo	   = sp_cob174(_no_documento);
	
	{if _saldo > 1.00 then
		update deivid_tmp:temp_venc2021abr
	       set cancelada = 0
		 where poliza = _no_documento; 
	end if}
	return _no_documento,_saldo,_no_poliza with resume;
	
END FOREACH

END PROCEDURE;