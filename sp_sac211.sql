-- *********************************
-- Procedimiento que genera el reporte de Comprobantes actualizados	 
-- Creado : Henry Giron Fecha : 28/03/2013
-- d_sac_sp_sac145_dw1
-- *********************************
DROP PROCEDURE sp_sac211;
CREATE PROCEDURE sp_sac211(a_db CHAR(18), a_fecha1 date, a_fecha2 date, a_auxiliar CHAR(5), a_tipo char(1)  )
RETURNING integer,
            char(50);

define _error		      integer;
define _error_isam	      integer;
define _error_desc	      char(50);

define _fecha          date;	
define _no_documento   char(20);
define _no_poliza      char(10);	
define _no_endoso      char(5);	
define _sac_notrx      char(10);
define _auxiliar       char(5);
define _auxiliar_nom   char(50);

define _cod_ramo	   char(3);
define _no_unidad	   char(5);
define _cod_cober_reas char(3);
define _cod_contrato   char(5);
define _serie		   integer;
define _bouquet		   integer;

define _no_tranrec     char(10);
define _no_remesa      char(10);


SET ISOLATION TO DIRTY READ;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

CREATE TEMP TABLE tmp_aux(
fecha         date,	
no_documento  char(20),		  
no_poliza     char(10),	 	
no_endoso     char(5),	 		
sac_notrx     char(10),	
auxiliar_nom  char(50),
no_tranrec    char(10),
no_remesa     char(10),
PRIMARY KEY(fecha,no_documento,no_poliza,no_endoso,sac_notrx,auxiliar_nom)) WITH NO LOG;
CREATE INDEX idx1_tmp_aux ON tmp_aux(no_documento);
CREATE INDEX idx2_tmp_aux ON tmp_aux(no_poliza);
CREATE INDEX idx3_tmp_aux ON tmp_aux(no_endoso);
CREATE INDEX idx4_tmp_aux ON tmp_aux(sac_notrx);
CREATE INDEX idx5_tmp_aux ON tmp_aux(auxiliar_nom);

if a_db = "sac" then

	FOREACH 
		select distinct c.fecha,
		       c.no_documento,
		       c.no_poliza,
		       c.no_endoso,
		       b.sac_notrx,
			   d.cod_auxiliar,
			   c.no_tranrec,
			   c.no_remesa 
		  into _fecha,
			   _no_documento,
			   _no_poliza,
			   _no_endoso,
			   _sac_notrx,
			   _auxiliar,
			   _no_tranrec,
			   _no_remesa 
		 from sac999:reacompasie b, sac999:reacomp c, 
		      sac999:reacompasiau d ,sac:cglterceros t
		where b.no_registro = c.no_registro
		  and c.tipo_registro = a_tipo --"1"
          and c.fecha >= a_fecha1  --'01/07/2011'
          and c.fecha <= a_fecha2  --'01/10/2011'
		  and d.no_registro = b.no_registro --'945361' -- i_no_registro
		  and d.cod_auxiliar = t.ter_codigo
          and d.cod_auxiliar = a_auxiliar -- in ('BQ050','BQ076') 
--		  and c.no_documento[1,2] not in ("04","16","18","19")

			select cod_ramo																	  
			  into _cod_ramo																  
			  from emipomae																	  
			 where no_poliza = _no_poliza;													  
																							  
	             if _cod_ramo  in ("004","016","018","019") then							  
				    continue foreach;
				 else
					if a_tipo in ("2","3") then
					   let _no_endoso = "00000";
					end if

					foreach
				     select no_unidad
					   into _no_unidad
					   from endeduni
					  where no_poliza = _no_poliza
					    and no_endoso = _no_endoso

						 foreach
						     select cod_cober_reas,
							        cod_contrato
							   into _cod_cober_reas,
									_cod_contrato
							   from emifacon
							  where no_poliza = _no_poliza
							    and no_endoso = _no_endoso
								and no_unidad = _no_unidad

									 Select serie
									   Into _serie
									   from reacomae
									  where cod_contrato = _cod_contrato;

						             if _serie	< 2008 then
									    continue foreach;
									 end if

							         select bouquet
									   into _bouquet
									   from reacocob
									  where cod_contrato = _cod_contrato
									    and cod_cober_reas = _cod_cober_reas;

						             if _bouquet	= 0 then
									    continue foreach;
									else

										SELECT ter_descripcion 
										  INTO _auxiliar_nom 
										  FROM sac:cglterceros
										 WHERE ter_codigo = _auxiliar;

									     BEGIN
									        ON EXCEPTION IN (-239,-268)
								           END EXCEPTION

											INSERT INTO tmp_aux(
											 fecha,
											 no_documento,
											 no_poliza,
											 no_endoso,
											 sac_notrx,
											 auxiliar_nom,
											 no_tranrec,
											 no_remesa 
											 )
											VALUES(	
											 _fecha,
											 _no_documento,
											 _no_poliza,
											 _no_endoso,
											 _sac_notrx,
											 _auxiliar_nom,
											 _no_tranrec,
											 _no_remesa  );  

								           END
									 end if
						end foreach

					end foreach
				 end if

	END FOREACH

end if

end 

return 0, "Actualizacion Exitosa";

end procedure 