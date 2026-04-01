--procedimiento para buscar info para corredor WTW
--24/03/2025

DROP procedure sp_wtw_am;
CREATE procedure sp_wtw_am()
RETURNING integer,integer,char(100);
		  

DEFINE _no_recibo,_no_poliza,_no_remesa 	CHAR(10);
DEFINE _no_documento        			    CHAR(20);
define _p_suscrita,_monto					dec(16,2);
define _monto_descontado,_comision          dec(16,2);
define _cliente,_error_desc                 char(100);
define _vig_inic_p,_vig_fin_p,_fecha_pago,_vig_ini   date;
define _renglon                             smallint;
define _por_comis,_porc_partic              dec(5,2);
define _error,_error_isam integer;

begin
on exception set _error,_error_isam,_error_desc 
 	return _error,_error_isam,_error_desc||"Poliza: "||_no_documento;
end exception

let _comision = 0.00;

foreach
	select no_documento,
		   cliente,
		   vig_ini
	  into _no_documento,
		   _cliente,
		   _vig_ini
	  from deivid_tmp:wtw_base
	 where procesado = 0
	 
	foreach
		select no_poliza,
		       vigencia_inic,
			   vigencia_final,
			   prima_suscrita
		  into _no_poliza,
		       _vig_inic_p,
			   _vig_fin_p,
			   _p_suscrita
		  from emipomae
		 where no_documento = _no_documento
		   and actualizado = 1
		   and vigencia_inic >= _vig_ini
		 order by vigencia_inic
		
		foreach
			select d.no_recibo,
			       d.fecha,
				   d.renglon,
				   d.prima_neta,
				   d.monto_descontado,
				   d.no_remesa
			  into _no_recibo,
                   _fecha_pago,
                   _renglon,
                   _monto,
				   _monto_descontado,
				   _no_remesa
			  from cobredet d, cobremae c
             where d.no_remesa = c.no_remesa
			   and d.no_poliza = _no_poliza
               and d.actualizado = 1
               and d.tipo_mov in('P','N')
			   and c.tipo_remesa in('A', 'M', 'C')
			
			let _comision = 0.00;
			
			select porc_comis_agt,
				   porc_partic_agt
			  into _por_comis,
				   _porc_partic
			  from cobreagt
			 where no_remesa  = _no_remesa
			   and renglon    = _renglon
			   and cod_agente in('00035','02154','02656','02904');	--WTW
			   
			if _por_comis is null then
				insert into deivid_tmp:wtw_salida(no_poliza,no_documento,cliente,no_recibo,fecha_pago,vigencia_inic,vigencia_final,porc_comis,monto,prima_suscrita,porc_partic,comision,
												  no_remesa,renglon,monto_descontado)
				values(_no_poliza,_no_documento,_cliente,"VIG. NO",_fecha_pago,_vig_inic_p,_vig_fin_p,0,0,0,0,0,_no_remesa,0,0);
				continue foreach;
			end if
			   
			let _comision = _monto * _porc_partic /100;
			let _comision = _comision * _por_comis /100;
			
			if _monto_descontado <> 0 then
				let _comision = _monto_descontado;
			end if

			insert into deivid_tmp:wtw_salida(no_poliza,no_documento,cliente,no_recibo,fecha_pago,vigencia_inic,vigencia_final,porc_comis,monto,prima_suscrita,porc_partic,comision,
			                                  no_remesa,renglon,monto_descontado)
			values(_no_poliza,_no_documento,_cliente,_no_recibo,_fecha_pago,_vig_inic_p,_vig_fin_p,_por_comis,_monto,_p_suscrita,_porc_partic,_comision,
			       _no_remesa,_renglon,_monto_descontado);
			
		end foreach
	end foreach
	update deivid_tmp:wtw_base
	   set procesado = 1
	  where no_documento = _no_documento;
end foreach

return 0,0,'Proceso Terminado';
end
END PROCEDURE;
