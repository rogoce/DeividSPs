--procedimiento para buscar info para corredores
--13/01/2026

DROP procedure sp_wtw_am3;
CREATE procedure sp_wtw_am3()
RETURNING integer,integer,char(100);
		  

DEFINE _no_recibo,_no_poliza,_no_remesa,_cod_contratante 	CHAR(10);
DEFINE _no_documento        			    CHAR(20);
define _p_suscrita,_monto					dec(16,2);
define _monto_descontado,_comision          dec(16,2);
define _cliente,_error_desc                 char(100);
define _vig_inic_p,_vig_fin_p,_fecha_pago,_vig_ini   date;
define _renglon                             smallint;
define _por_comis,_porc_partic              dec(5,2);
define _error,_error_isam integer;
define _cod_tercero,_cod_tercero_aux       char(5);

begin
on exception set _error,_error_isam,_error_desc 
 	return _error,_error_isam,_error_desc||"Poliza: "||_no_documento;
end exception

let _comision = 0.00;

foreach
	select cod_tercero
	  into _cod_tercero
	  from deivid_tmp:data_aux_ter
	 where procesado = 0
	 
	let _cod_tercero_aux = _cod_tercero;
	let _cod_tercero[1,1] = "0";
	 
		foreach
			select d.no_recibo,
			       d.fecha,
				   d.renglon,
				   d.prima_neta,
				   d.monto_descontado,
				   d.no_remesa,
				   e.porc_comis_agt,
				   e.porc_partic_agt,
				   d.no_poliza
			  into _no_recibo,
                   _fecha_pago,
                   _renglon,
                   _monto,
				   _monto_descontado,
				   _no_remesa,
				   _por_comis,
				   _porc_partic,
				   _no_poliza
			  from cobredet d, cobremae c, cobreagt e
             where d.no_remesa = c.no_remesa
			   and d.no_remesa = e.no_remesa
			   and d.renglon   = e.renglon
               and d.actualizado = 1
               and d.tipo_mov in('P','N')
			   and d.fecha           <= '31/12/2025'
			   and c.tipo_remesa in('A', 'M', 'C')
			   and e.cod_agente = _cod_tercero
			
			select no_documento,
				   vigencia_inic,
				   vigencia_final,
				   prima_suscrita,
				   cod_contratante
			  into _no_documento,
				   _vig_inic_p,
				   _vig_fin_p,
				   _p_suscrita,
				   _cod_contratante
			  from emipomae
			 where no_poliza = _no_poliza
			   and actualizado = 1;
			
			let _comision = 0.00;

			select nombre 
			  into _cliente
			  from cliclien
			 where cod_cliente = _cod_contratante;
			
			if _por_comis is null then
				insert into deivid_tmp:wtw_salida(no_poliza,no_documento,cliente,no_recibo,fecha_pago,vigencia_inic,vigencia_final,porc_comis,monto,prima_suscrita,porc_partic,comision,
												  no_remesa,renglon,monto_descontado,cod_agente)
				values(_no_poliza,_no_documento,_cliente,"VIG. NO",_fecha_pago,_vig_inic_p,_vig_fin_p,0,0,0,0,0,_no_remesa,0,0,_cod_tercero);
				continue foreach;
			end if
			   
			let _comision = _monto * _porc_partic /100;
			let _comision = _comision * _por_comis /100;
			
			if _monto_descontado <> 0 then
				let _comision = _monto_descontado;
			end if

			insert into deivid_tmp:wtw_salida(no_poliza,no_documento,cliente,no_recibo,fecha_pago,vigencia_inic,vigencia_final,porc_comis,monto,prima_suscrita,porc_partic,comision,
			                                  no_remesa,renglon,monto_descontado,cod_agente)
			values(_no_poliza,_no_documento,_cliente,_no_recibo,_fecha_pago,_vig_inic_p,_vig_fin_p,_por_comis,_monto,_p_suscrita,_porc_partic,_comision,
			       _no_remesa,_renglon,_monto_descontado,_cod_tercero);
			
		end foreach
	
	let _cod_tercero = _cod_tercero_aux;
	
	update deivid_tmp:data_aux_ter
	   set procesado = 1
	 where cod_tercero = _cod_tercero;

	return 0,0, _cod_tercero with resume;
end foreach

return 0,0,'Proceso Terminado';
end
END PROCEDURE;
