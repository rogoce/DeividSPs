-- Reversar Asientos de Reaseguro de Cobros de Pólizas del Bouquet Caso 3875

drop procedure ap_reversa_asiento2;

create procedure "informix".ap_reversa_asiento2()
returning integer,integer,char(80);

define _no_requis		char(10);
define _transaccion     char(10);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _sac_notrx		integer;
define _res_origen      char(3);
 
let _sac_notrx = null;
let _error = 0;
let _error_desc = "";

--SET LOCK MODE TO WAIT;

--set debug file to "aa.trc";
--trace on;
set isolation to dirty read;

--foreach
--  SELECT distinct d.sac_notrx
--    INTO _sac_notrx
--    FROM emipomae a, cobredet b, sac999:reacomp c, sac999:reacompasie d
--   WHERE (a.no_documento = b.doc_remesa) and
--         ( b.no_remesa = c.no_remesa) and
--         ( b.renglon = c.renglon) and
--         ( c.no_registro = d.no_registro) and
--         ( a.vigencia_inic >= '01/07/2022' ) AND
--         ( a.cod_ramo in ( '001','003','010','011','012','013','014','021','022','006' ) ) AND
--         ( a.actualizado = 1 )  and
--         ( b.periodo = '2022-06')

--	call sp_sac77(_sac_notrx) returning _error, _error_desc;
		
--	return _sac_notrx, 
--	       _error, 
--		   _error_desc with resume;
--end foreach


--foreach
--	select distinct b.sac_notrx
--	  into _sac_notrx
--	  from sac999:reacomp a, sac999:reacompasie b
--	 where a.no_registro = b.no_registro
--	   and a.periodo = '2022-08'
--	   and a.no_documento[1,2] in ('04','16','19')
--	order by 1
	
--	call sp_sac77(_sac_notrx) returning _error, _error_desc;
		
--	return _sac_notrx, 
--	       _error, 
--		   _error_desc with resume;	
--end foreach

foreach
	select sac_asiento,
	       res_origen
	  into _sac_notrx,
	       _res_origen
	  from tmp_rever_asi2
	 where procesado = 0
	  -- and sac_asiento = 1426469
	order by 1
	
	call sp_sac258(_sac_notrx, _res_origen) returning _error, _error_desc;
	
	if _error = 0 then
		update tmp_rever_asi2
		   set procesado = 1
		 where sac_asiento = _sac_notrx;
	end if	 
		
	return _sac_notrx, 
	       _error, 
		   _error_desc with resume;	
end foreach

end procedure
