-- Reporte de Polizas de Canceladas Anticipadas
-- Creado : 30/03/2021 - Autor: Henry Giron
-- SIS v.2.0 - d_cob_sp_pro1024_dw1 - DEIVID, S.A.  
-- execute procedure sp_pro1024('001','001','11/07/2017','15/07/2017')

drop procedure sp_pro1024;
create procedure sp_pro1024(
a_compania 		char(3),
a_agencia  		char(3),
a_fecha1 date,
a_fecha2 date)

returning  char(50) As Canal,
		char(5) 	As Sucursal,
		char(50) 	As Ejecutivo,         --  Ejecutivo Comercial a cargo,
		char(50) 	As Producto,
		char(20)	As Poliza,            --  Numero de Póliza
		dec(16,2)	As Prima,
		date		As Vig_Inicial,          --adicional1
		date		As Vig_Final,            --adicional2
		date		As Fecha_Emision,     --  Fecha De Emisión
		char(100) 	As Corredor,          --  Nombre Del Corredor
		char(100) 	As Asegurado,         --  Nombre del Asegurado
		date		As Fecha_suscripcion, --  Fecha de emisión de la póliza
		char(8) 	As user_cancela ,     --  Solicitante de la Cancelación
		date		As Fecha_Cancela,     --  Fecha De Cancelación
		dec(16,2) 	As Monto_Cancela,     --  Monto De Cancelación
		dec(16,2) 	As Monto_devolucion , --  Monto de devolución
		varchar(50) As Beneficiario,      --  Nombre de Beneficiario del cheque o de la transferencia bancaria
		varchar(50) As Motivo_cancelacion ,  -- Motivo de cancelación
		varchar(50) As pagador,              -- Nombre del pagador
		varchar(50) as Cia;	

define _mensaje				varchar(250);
define _nom_agente			varchar(50);
define _nombre_cli			varchar(50);
define _cia_nombre          varchar(50); 
define _no_documento		char(20);
define _cod_cliente			char(10);
define _no_poliza			char(10);
define _user_cancela		char(8);
define _periodo         	char(7);
define _cod_ramo            char(3); 
define _cod_tipocan         char(3); 
define _prima_bruta			dec(16,2);
define _por_vencer     		dec(16,2);
define _corriente			dec(16,2);
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);
define _monto_90			dec(16,2);
define _exigible       		dec(16,2);
define _saldo				dec(16,2);
define _estatus_poliza		smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_suscripcion	date;
define _fecha_primer_pago	date;
define _fecha_emision       date;
define _fecha_cancela       date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_ult_dia		date;
define _fecha_actual		date;
define _suc_prom        	char(5);
define _cod_sucursal       	char(5);
define _cod_vendedor		char(3);
define _nombre_vendedor	    char(50);
define _cod_producto        char(5);
define _Nombre_Producto     char(50);
define _cnt 				integer;
define _canal               char(50);
define _cod_pagador      	CHAR(10);
define _nombre_pag			varchar(50);
define _cod_cliente_ben    	CHAR(10);
define _nom_cliente_ben	    varchar(50);
define _motivo_cancelacion  varchar(50);
define _cod_agente          char(5); 
define _no_unidad		    char(5);   
define _porc_partic_ben     dec(5,2);
	
set isolation to dirty read;
begin
on exception set _error,_error_isam,_mensaje	
 	return '','','','','',0.00,null,null,null,'','',null,'',null,0.00,0.00,'','','','';		   	 			   
end exception

let  _cia_nombre = sp_sis01('001'); 
let _fecha_actual = date(current);
let _canal = '';
let _error = 0;
 
call sp_sis39(_fecha_actual) returning _periodo;
call sp_sis36(_periodo) returning _fecha_ult_dia;

foreach
	select x.no_poliza,
		   x.no_documento,		  
		   x.fecha_emision,
		   x.user_added,
		   x.cod_tipocan 
	  into _no_poliza,
		   _no_documento,
		   _fecha_cancela,
		   _user_cancela,
		   _cod_tipocan 
	  from emipomae e, endedmae x
	 where e.no_poliza   = x.no_poliza
	   and e.nueva_renov = 'N' 
	   and e.actualizado = 1
	   and x.cod_endomov = '002'  -- cancelacion 	
       and x.fecha_emision >= a_fecha1
	   and x.fecha_emision <= a_fecha2

   
	   --Tipo de Cancelacion
       select trim(nombre)
	     into _motivo_cancelacion
	     from endtican
	    where cod_tipocan = _cod_tipocan;	
	
	select trim(no_documento),
	       cod_sucursal,
	       cod_ramo,
	       vigencia_inic,
		   vigencia_final,
		   estatus_poliza,		   
		   fecha_primer_pago,
		   fecha_suscripcion,		   
		   prima_bruta,		  
		   cod_contratante,
		   fecha_emision,
		   cod_pagador
	  into _no_documento,
	       _cod_sucursal,
	       _cod_ramo,
	       _vigencia_inic,
		   _vigencia_final,
		   _estatus_poliza,		   		   		   
		   _fecha_primer_pago,
		   _fecha_suscripcion,		   
		   _prima_bruta,		   
		   _cod_cliente,
		   _fecha_emision,
		   _cod_pagador
	  from emipomae
	 where no_poliza = _no_poliza
	   and nueva_renov = 'N'
       and estatus_poliza = 2;

	CALL sp_cob33(
				a_compania,
				a_agencia,
				_no_documento,
				_periodo,
				_fecha_ult_dia)
	RETURNING	_por_vencer,
				_exigible,  
				_corriente,
				_monto_30,  
				_monto_60,  
				_monto_90,
				_saldo;
				
	if _saldo is null then
		let _saldo = 0;
	end if					
    --Sacar el corredor
	foreach
		select cod_agente,a.nombre
		  into _cod_agente,_nom_agente
		  from emipoagt e, agtagent a
		 where e.cod_agente = a.cod_agente
		   and e.no_poliza = _no_poliza
		 order by porc_partic_agt desc
		exit foreach;
	end foreach

	select sucursal_promotoria
	  into _suc_prom
	  from insagen
	 where codigo_agencia  = _cod_sucursal
	   and codigo_compania = '001';  


   select cod_vendedor
	 into _cod_vendedor
	 from parpromo
	where cod_agente  = _cod_agente
	  and cod_agencia = _suc_prom
	  and cod_ramo	   = _cod_ramo;
	
	select nombre
	  into _nombre_vendedor
	  from agtvende
	 where cod_vendedor = _cod_vendedor;		

	select trim(nombre)
	  into _nombre_cli
	  from cliclien
	 where cod_cliente = _cod_cliente;		   	 	
	 
	select trim(nombre)
	  into _nombre_pag
	  from cliclien
	 where cod_cliente = _cod_pagador;		      
	 
	foreach 
	 select	no_unidad, cod_producto
	   into	_no_unidad, _cod_producto
	   from	endeduni
	  where	no_poliza = _no_poliza
		exit foreach;
	end foreach	 
	
	select trim(nombre)
	  into _Nombre_Producto	  
	  from prdprod
	 where cod_producto = _cod_producto;	
	 
	let _cnt = 0; 
	select count(*)
	  into _cnt
	  from emibenef
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;   

		if _cnt is null then
			let _cnt = 0;
		end if
		
		
		if _cnt > 0 then	
			foreach			
			select porc_partic_ben,
				   cod_cliente
			  into _porc_partic_ben,
				   _cod_cliente_ben
			  from emibenef
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   
				exit foreach;
			end foreach	 
	  end if
	  
	select trim(nombre)
	  into _nom_cliente_ben
	  from cliclien
	 where cod_cliente = _cod_cliente_ben;	 	  
	   
	let _cnt = 0;
	
	select count(*)
	  into _cnt
	  from agtagent
	 where cod_agente = _cod_agente
	   and no_licencia[1,3] = 'OAL'; 	  
	 
		if _cnt is null then
			let _cnt = 0;
		end if
		
		if _cnt > 0 then 
			let _canal = 'BAC INTERNATIONAL BANK INC.';
	   else
	   	    let _canal = _nom_agente;
		end if					   	 		
	
	return _canal,
			_cod_sucursal,
			_nombre_vendedor,
			_Nombre_Producto,
			_no_documento,
			_prima_bruta,
			_vigencia_inic,
			_vigencia_final,	
			_fecha_emision,
			_nom_agente,
			_nombre_cli,
			_fecha_suscripcion,
			_user_cancela,
			_fecha_cancela,
			_prima_bruta,     
			_saldo,  --As Monto_devolucion , --  Monto de devolución
			_nom_cliente_ben,
			_motivo_cancelacion,
			_nombre_pag,              
			_cia_nombre
		   with resume;	 	 
	

	
end foreach
--trace off;
end
end procedure;
