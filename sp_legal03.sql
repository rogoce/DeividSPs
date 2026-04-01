-- Reporte de Polizas de Canceladas Anticipadas
-- Creado : 30/03/2021 - Autor: Henry Giron
-- SIS v.2.0 - d_cob_sp_legal03_dw1 - DEIVID, S.A.  
-- execute procedure sp_legal03('001','001','01/03/2021','01/04/2021')

drop procedure sp_legal03;
create procedure sp_legal03(
a_compania char(3),
a_agencia  char(3),
a_fecha1   date,
a_fecha2   date)

returning  char(50) As Canal,
		char(30) 	As Sucursal,
		char(50) 	As Ejecutivo_comercial, --  Ejecutivo Comercial a cargo,
		char(50) 	As Producto,
		char(20)	As Poliza,              --  Numero de Póliza
		dec(16,2)	As Prima_Suscrita,
		date		As Vig_Inicial,         --  Vigencia Inicial
		date		As Vig_Final,           --  Vigencia Final
		date		As Fecha_Emision,     	--  Fecha de Emisión del endoso de cancelación
		char(100) 	As Nombre_Corredor,     --  Nombre Del Corredor
		char(10)    As Cod_cliente,         --  codigo de contratante
		char(100) 	As Nombre_Asegurado,    --  Nombre del Asegurado
		date		As Fecha_emision_pol, 	--  Fecha de emisión de la póliza
		date		As Fecha_Cancela,     	--  Fecha De Cancelación
		dec(16,2) 	As Monto_Cancela,     	--  Monto De Cancelación
		dec(16,2) 	As Monto_devolucion , 	--  Monto de devolución
		varchar(50) As Beneficiario_chq,    --  Nombre de Beneficiario del cheque o de la transferencia bancaria
		varchar(50) As Motivo_cancelacion , --  Motivo de cancelación
		varchar(50) As Nombre_pagador,      --  Nombre del pagador
		char(30)  as usuario_cancela;        --  Usuario Cancela
		
		
define _mensaje				varchar(250);	
define _nombre_cli			varchar(50);
define _nom_agente			varchar(50);
define _nombre_pag			varchar(50);
define _nom_cliente_ben	    varchar(50);
define _motivo_cancelacion  varchar(50);
define _no_documento		char(20);
define _cod_cliente			char(10);
define _no_requis           char(10);
define _nombre_vendedor	    char(50);
define _nombre_ramo         char(50);
define _canal               char(50);
define _cod_pagador      	CHAR(10);
define _no_poliza			char(10);
define _user_cancela		char(8);
define _cod_ramo            char(3); 
define _cod_tipocan         char(3); 
define _cod_sucursal       	char(5);
define _cod_vendedor,_cod_subramo	char(3);
define _error_isam			integer;
define _error				integer;
define _monto_devolucion    dec(16,2);
define _prima_suscrita_canc	dec(16,2);
define _prima_suscrita		dec(16,2);
define _fecha_suscripcion	date;
define _fecha_cancelacion	date;
define _fecha_emision       date;
define _fecha_cancela       date;
define _fecha_endoso        date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _sucursal            char(30);
define _cod_producto        char(5);
define _Nombre_Producto     char(50);
define _no_unidad		    char(5);   
define _usuario_cancelo     char(30);
	
set isolation to dirty read;
begin
on exception set _error,_error_isam,_mensaje	
 	return '','','','','',0.00,null,null,null,'','','',null,null,0.00,0.00,'','','','';		   	 			   
end exception
 --SET DEBUG FILE TO "sp_pro1024.trc";      
 --TRACE ON;   
let _canal = '';
let _error = 0; 

foreach
	select no_poliza,
	       fecha_cancelacion,
		   trim(no_documento),
	       cod_sucursal,
	       cod_ramo,
	       vigencia_inic,
		   vigencia_final,		   		   
		   fecha_suscripcion,		   
		   prima_suscrita,		  
		   cod_contratante,
		   date_added,
		   cod_pagador,
		   cod_subramo		   
	  into _no_poliza,
	       _fecha_cancelacion,
		   _no_documento,
	       _cod_sucursal,
	       _cod_ramo,
	       _vigencia_inic,
		   _vigencia_final,
		   _fecha_suscripcion,		   
		   _prima_suscrita,		   
		   _cod_cliente,
		   _fecha_emision,
		   _cod_pagador,
		   _cod_subramo
	  from emipomae
	 where actualizado = 1
	   and estatus_poliza = 2
	   and nueva_renov = 'N'
	   and fecha_cancelacion <= vigencia_final
	   and fecha_suscripcion between  a_fecha1 and a_fecha2   -- por mientras  	   
	   
	let _monto_devolucion = 0;
	let _no_requis = null;
	let _nom_cliente_ben = '';
	
	foreach
		select no_requis, sum(monto)
		  into _no_requis, _monto_devolucion
		  from chqchpol
		 where no_poliza = _no_poliza
		 group by no_requis	
		 order by no_requis	desc 
		 
		 exit foreach;
	end foreach

	select a_nombre_de
	  into _nom_cliente_ben
	  from chqchmae
	 where no_requis = _no_requis;
	 
	if _monto_devolucion <= 0 then
	    continue foreach;
	end if	   
	
	select descripcion
	  into _sucursal
	  from insagen
	 where codigo_agencia  = _cod_sucursal
	   and codigo_compania = "001";	   	
	   
	foreach   
		select no_documento,		  
			   fecha_emision,
			   user_added,
			   cod_tipocan,
			   prima_suscrita
		  into _no_documento,
			   _fecha_endoso,
			   _user_cancela,
			   _cod_tipocan,
			   _prima_suscrita_canc
		  from endedmae
		 where actualizado = 1
		   and cod_endomov = '002'  -- cancelacion 
		   and no_poliza = _no_poliza
		 order by fecha_emision desc
	  exit foreach;
	end foreach

    --Tipo de Cancelacion
	select trim(nombre)
	  into _motivo_cancelacion
	  from endtican
	 where cod_tipocan = _cod_tipocan;
	
    --Sacar el corredor
	foreach
		select a.nombre,a.cod_vendedor
		  into _nom_agente,_cod_vendedor
		  from emipoagt e, agtagent a
		 where e.cod_agente = a.cod_agente
		   and e.no_poliza = _no_poliza
		 order by porc_partic_agt desc, a.nombre asc
		exit foreach;
	end foreach
 
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
	 
	let _nombre_ramo = '';
	
	select nombre
	  into _nombre_ramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
       and cod_subramo = _cod_subramo;	 
	   
	select b.nombre
      into _canal
	  from ponderacion a, clicanal b
	 where a.cod_cliente = _cod_cliente
	   and a.cod_canal = b.cod_canal;	   	   		   	   
	   
	select descripcion
      into _usuario_cancelo
	  from insuser
	 where usuario = _user_cancela;	   
	
	return _canal,
			_sucursal,
			_nombre_vendedor,
			_nombre_ramo,
			_no_documento,
			_prima_suscrita,
			_vigencia_inic,
			_vigencia_final,	
			_fecha_endoso,   -- fecha_emision endoso
			_nom_agente,
			_cod_cliente,
			_nombre_cli,
			_fecha_suscripcion,			
			_fecha_cancelacion,   --_fecha_emision,
			_prima_suscrita_canc,     
			_monto_devolucion,  
			_nom_cliente_ben,
			_motivo_cancelacion,
			_nombre_pag,
			_usuario_cancelo
		   with resume;	 	 
end foreach
--trace off;
end
end procedure;
