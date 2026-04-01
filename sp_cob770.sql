-- Procedure que crea la remesa tipo B en negativo  
-- Creado    : 27/09/2016 - Autor: Henry Girón       
-- SIS v.2.0 - DEIVID, S.A.  
drop procedure sp_cob770;    
create procedure sp_cob770(a_no_remesa char(10),a_usuario char(8))  
returning integer, 
          char(100), 
          char(10); 

define _error_desc		char(100); 
define _ult_no_recibo   char(10);  
define _no_remesa		char(10);  
define _no_recibo    	char(10);  
define _user_added      char(8);   
define _cod_libreta  	char(5);   
define _cod_chequera 	char(3);  
define _cod_cobrador    char(3);  
define _error_isam		integer;  
define _cantidad        integer;
define _error			integer;
define _tipo_remesa 	char(1);
define _fecha_hoy		date;
define _fecha_remesa	date;
define _max_renglon     smallint;
define _cnt             smallint;
define li_caja_abierta  smallint;
define _anula_tipo_mov  char(1);
define _actualizado			smallint;
define _fecha_datetime	datetime year to second;

on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc,''; 
end exception 

SET ISOLATION TO DIRTY READ; 
let _actualizado = 0;

select tipo_remesa,fecha,cod_cobrador,user_added,cod_chequera,actualizado 
  into _tipo_remesa,_fecha_remesa,_cod_cobrador,_user_added,_cod_chequera,_actualizado
  from cobremae
 where no_remesa = a_no_remesa;  
 
  if _actualizado <> 1 then
	return 1, 'Remesa a Anular no ha sido actualizada ...',''; 
end if	
 
let _fecha_hoy = current; 
let _fecha_datetime = current; 
let li_caja_abierta = 0;

   let _cnt = 0; 
select count(*) 
  into _cnt 
  from cobcieca 
 where fecha        = _fecha_remesa 
   and cod_chequera = _cod_chequera  
   and tipo_remesa  = _tipo_remesa 
   and actualizado  = 0; 
   
if _cnt = 0 then 
	return 1, 'Caja para la fecha seleccionada esta Cerrada, Por favor verifique ...','';  
else 
	let li_caja_abierta = 1;
end if 

if li_caja_abierta <> 1 then 
	if _fecha_remesa <> _fecha_hoy  then 
		return 1, 'Remesa a anular no pertenece al mismo dia ...',''; 
	end if
end if	

if _tipo_remesa <> 'A' and _tipo_remesa <> 'M' then		
	return 1, 'Remesa a Anular solo es permitido para remesa automatica y manual ...',''; 
end if	

foreach 
	select no_recibo   --,(case when tipo_mov  = 'P' then 'N' else (case when tipo_mov  = 'E' then 'A' else tipo_mov end ) end )
	  into _no_recibo  --,_anula_tipo_mov 
	  from cobredet    
	 where no_remesa = a_no_remesa 
	  exit foreach; 
end foreach

let _max_renglon   = 0;
let _no_remesa     = '00000';
let _ult_no_recibo = '00000';

begin
	let _no_remesa = sp_sis13("001", 'COB', '02', 'par_no_remesa');
	select count(*)
	  into _cantidad
	  from cobremae
	 where no_remesa = _no_remesa;

	if _cantidad <> 0 then
		return 1, 'El numero de remesa generado ya existe, por favor actualice nuevamente...','';
	end if
	
	select cod_libreta
	  into _cod_libreta
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	select ult_no_recibo 
	  into _ult_no_recibo 
	  from coblibre 
	 where cod_libreta = _cod_libreta; 
		
    --crear temporal cobremae_tmp e insertar nueva remesa de produccion 
	select * from cobremae	where 1 = 2 into temp cobremae_tmp;  
    insert into cobremae_tmp  
         ( no_remesa,cod_compania,cod_sucursal,cod_banco,cod_cobrador,recibi_de,tipo_remesa,fecha,comis_desc,contar_recibos,monto_chequeo,  
           actualizado,periodo,user_added,date_added,user_posteo,date_posteo,subir_bo,cod_chequera,hora_creacion,hora_impresion )  
     select _no_remesa,cod_compania,cod_sucursal,cod_banco,cod_cobrador,"Recibo Anulado:"||_no_recibo||",Remesa:"||no_remesa,tipo_remesa,fecha,comis_desc,contar_recibos,monto_chequeo*-1,  
--     select _no_remesa,cod_compania,cod_sucursal,cod_banco,cod_cobrador,recibi_de,tipo_remesa,fecha,comis_desc,contar_recibos,monto_chequeo*-1,  
            0,periodo,a_usuario,date_added,user_posteo,date_posteo,0,cod_chequera,_fecha_datetime,_fecha_datetime  
       from cobremae  
      where cobremae.no_remesa = a_no_remesa;  
	
    --crear temporal cobredet_tmp e insertar nueva remesa  
	select *  from cobredet  where 1 = 2 into temp cobredet_tmp;  
    insert into cobredet_tmp  
         ( no_remesa,renglon,cod_compania,cod_sucursal,no_poliza,no_unidad,no_tranrec,cod_recibi_de,no_reclamo,cod_cobertura,  
           no_recibo,doc_remesa,tipo_mov,monto,prima_neta,impuesto,monto_descontado,comis_desc,desc_remesa,saldo,periodo,  
           fecha,actualizado,cod_agente,cod_auxiliar,sac_asientos,subir_bo,flag_web_corr,no_recibo2,gastos_manejo,nueva_renov )  
     select _no_remesa,renglon,cod_compania,cod_sucursal,no_poliza,no_unidad,no_tranrec,cod_recibi_de,no_reclamo,cod_cobertura,  
            no_recibo,doc_remesa,(case when tipo_mov  = 'P' then 'N' else (case when tipo_mov  = 'E' then 'A' else tipo_mov end ) end ), 
			monto*-1,prima_neta*-1,impuesto*-1,monto_descontado*-1,comis_desc*-1,desc_remesa,saldo*-1,periodo, 
            fecha,actualizado,cod_agente,cod_auxiliar,sac_asientos,subir_bo,flag_web_corr,no_recibo2,gastos_manejo,nueva_renov 
       from cobredet   
      where no_remesa = a_no_remesa ;
	
	select max(renglon) into _max_renglon from cobredet_tmp;

    -- Inserta en cobredet_tmp movimiento 'B'  
    insert into cobredet_tmp   
         ( no_remesa,renglon,cod_compania,cod_sucursal,no_poliza,no_unidad,no_tranrec,cod_recibi_de,no_reclamo,cod_cobertura,  
           no_recibo,doc_remesa,tipo_mov,monto,prima_neta,impuesto,monto_descontado,comis_desc,desc_remesa,saldo,periodo,  
           fecha,actualizado,cod_agente,cod_auxiliar,sac_asientos,subir_bo,flag_web_corr,no_recibo2,gastos_manejo,nueva_renov )  
     select _no_remesa,_max_renglon+1,cod_compania,cod_sucursal,no_poliza,no_unidad,no_tranrec,cod_recibi_de,no_reclamo,cod_cobertura, 
            no_recibo,no_recibo,'B',0,0,0,0,0,"Recibo Anulado:"||no_recibo||",Remesa:"||no_remesa,0,periodo, 
            fecha,actualizado,cod_agente,cod_auxiliar,sac_asientos,subir_bo,flag_web_corr,no_recibo2,gastos_manejo,nueva_renov 
       from cobredet  
      where no_remesa = a_no_remesa and renglon = _max_renglon; 
	  
          {    
	 values(_no_remesa,_renglon,_cod_compania,_cod_sucursal,_no_poliza,_no_unidad,_no_tranrec,_cod_recibi_de,_no_reclamo,_cod_cobertura,  
          _no_recibo,_doc_remesa,_tipo_mov,_monto,_prima_neta,_impuesto,_monto_descontado,_comis_desc,_desc_remesa,_saldo,_periodo,  
          _fecha,_actualizado,_cod_agente,_cod_auxiliar,_sac_asientos,_subir_bo,_flag_web_corr,_no_recibo2,_gastos_manejo,_nueva_renov)  
		  } 

    --crear temporal cobreagt_tmp e insertar nueva remesa 
    select * from cobreagt where 1 = 2 into temp cobreagt_tmp; 
    insert into cobreagt_tmp 
         ( no_remesa,renglon,cod_agente,monto_calc,monto_man,porc_comis_agt,porc_partic_agt,flag_web_corr ) 
     select _no_remesa,renglon,cod_agente,monto_calc*-1,monto_man*-1,porc_comis_agt,porc_partic_agt,flag_web_corr 
       from cobreagt  
      where no_remesa = a_no_remesa; 

    --crear temporal cobrepag_tmp e insertar nueva remesa
    select * from cobrepag where 1 = 2 into temp cobrepag_tmp;	
  insert into cobrepag_tmp  
         ( no_remesa,renglon,tipo_pago,tipo_tarjeta,cod_banco,   
           fecha,no_cheque,girado_por,a_favor_de,importe,tipo_cheque )  
     select _no_remesa,renglon,tipo_pago,tipo_tarjeta,cod_banco,
            fecha,no_cheque,girado_por,a_favor_de,importe*-1,1
       from cobrepag  
      where no_remesa = a_no_remesa;
	  
    --adiciona remesa
insert into cobremae  select * from cobremae_tmp;
insert into cobredet  select * from cobredet_tmp;
insert into cobreagt  select * from cobreagt_tmp;
insert into cobrepag  select * from cobrepag_tmp;    

     --elimina temporal
drop table cobremae_tmp;
drop table cobredet_tmp;
drop table cobreagt_tmp;
drop table cobrepag_tmp;

--actualiza la remesa anulada
call sp_cob29(_no_remesa, a_usuario) returning _error, _error_desc;
if _error <> 0 then
	return _error, _error_desc,'';
end if

-- despliega remesa nueva de anulacion
return 0, _ult_no_recibo,_no_remesa;

end
end procedure 



	