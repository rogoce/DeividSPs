-- Consulta de Movimientos de Cuentas Sac x Transaccion de reclamos
-- Creado    : 07/06/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac185('01/01/2010','31/05/2010')

DROP PROCEDURE sp_sac185;
CREATE PROCEDURE sp_sac185(f_inicio date, f_final  date) 
RETURNING	INTEGER,
			char(10),
			DECIMAL(16,2),
			char(10),
			char(7),
			char(10),
			char(10),
			char(3),
			char(1),
			date,
			char(8);

DEFINE _res_notrx		INTEGER;
DEFINE _no_tranrec		char(10);
DEFINE _monto			DECIMAL(16,2);
DEFINE _transaccion		char(10);
DEFINE _periodo			char(7);
DEFINE _no_reclamo		char(10);
DEFINE _no_poliza		char(10);
DEFINE _cod_tipoprod	char(3);
DEFINE _coaseguro		char(1);
DEFINE _fecha			date;
DEFINE _user			char(8);

SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_sac185.trc";	
--  trace on;

--select * from deivid:rectrmae where no_tranrec in ( select no_tranrec from deivid:recasien where cuenta = '541020103' and sac_notrx in (
--select distinct res_notrx
--from cglresumen where res_cuenta = '541020103' and res_comprobante = 'REC011011'   and year(res_fechatrx) = 2010 and month(res_fechatrx)  = 1
--)
--)

FOREACH
	select distinct res_notrx
	  into _res_notrx
      from sac:cglresumen 
     where res_cuenta = '541020103' 
       and res_comprobante[1,3] = 'REC'   
       and res_fechatrx  >= f_inicio
       and res_fechatrx  <= f_final
--	   order by res_fechatrx

		FOREACH
			select no_tranrec 
			  into _no_tranrec 
			  from deivid:recasien 
			 where cuenta = '541020103' 
			   and sac_notrx = _res_notrx

			 SELECT monto,
					transaccion,
					periodo,
					no_reclamo,
					fecha,
					user_added
			   INTO _monto,
   				    _transaccion,
					_periodo,
					_no_reclamo,
					_fecha,
					_user
			   FROM deivid:rectrmae
			  WHERE no_tranrec = _no_tranrec	  
			    AND actualizado = 1;

				select no_poliza
				  into _no_poliza
				  from deivid:recrcmae
				 where no_reclamo = _no_reclamo;

				 SELECT	cod_tipoprod
				  INTO	_cod_tipoprod
				   FROM	deivid:emipomae
				  WHERE no_poliza = _no_poliza;

				LET _coaseguro = ' ';

				if 	_cod_tipoprod = '001' then
					LET _coaseguro = '*';
				end if

			  RETURN _res_notrx,	
					 _no_tranrec,	
					 _monto,		
					 _transaccion,	
					 _periodo,		
					 _no_reclamo,	
					 _no_poliza,	
					 _cod_tipoprod,
					 _coaseguro,	
					 _fecha,		
					 _user		
			    	 WITH RESUME;
		   
		END FOREACH;
   
END FOREACH;

END PROCEDURE					 