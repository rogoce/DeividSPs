-- Procedimiento para el reporte de Registros Procesados de una campana
-- Creado    : 15/07/2011 - Autor: Roman Gordon

drop procedure sp_cob284b;
create procedure "informix".sp_cob284b(a_cod_campana char(10)) 
returning char(20),	  	--1 _no_documento		  
		  char(50),	  	--2 _nom_ramo
		  char(50),	  	--3 _nom_subramo
		  char(50),	  	--4 _nom_formapag
		  char(50),	  	--5 _zona
		  char(50),	  	--6 _nom_agente
		  char(50),	  	--7 _nom_agencia
		  char(5),	  	--8 _cod_area
		  char(10),	  	--9 _status
		  char(50),	  	--10_nom_grupo
		  char(3),	  	--11_cod_pagos
		  char(50),	  	--12_nom_pagador
		  smallint,	  	--13_dia_cobros1  
		  smallint,	  	--14_dia_cobros2  
		  date,		  	--15_vigencia_inic
		  date,		  	--16_vigencia_fin
		  dec(16,2),  	--17_exigible
		  dec(16,2),  	--18_por_vencer
		  dec(16,2),  	--19_corriente
		  dec(16,2),  	--20_monto_30
		  dec(16,2),  	--21_monto_60
		  dec(16,2),  	--22_monto_90
		  dec(16,2),  	--23_monto_120
		  dec(16,2),  	--24_monto_150
		  dec(16,2),  	--25_monto_180
		  dec(16,2),  	--26_saldo
		  dec(16,2),  	--27_prima_bruta
		  char(15),   	--28_acreencia
		  date,		  	--29_fecha_aviso_canc
		  varchar(50),	--30_motivo_rechazo
		  char(7),		--31_fecha_exp
		  char(10),	  	--32_no_remesa
		  varchar(50);

define _motivo_rechazo  	varchar(50);
define _nom_gestion  		varchar(50);
define _nom_formapag		char(50);
define _no_documento		char(20);
define _nom_subramo			char(50);
define _nom_agencia			char(50);
define _nom_pagador			char(50);
define _nom_agente			char(50);
define _nom_grupo			char(50);
define _nom_ramo			char(50);
define _zona				char(50);
define _acreencia			char(15);
define _cod_pagador   		char(10);
define _cod_cliente			char(10);
define _no_poliza			char(10);
define _no_remesa			char(10);
define _status				char(10);
define _fecha_exp			char(7);
define _periodo				char(7);
define _cod_agente   		char(5);
define _cod_grupo   		char(5);  
define _cod_area   			char(5);
define _cod_formapag   		char(3);
define _cod_sucursal   		char(3);
define _cod_subramo   		char(3);
define _cod_gestion   		char(3);
define _cod_pagos   		char(3);
define _cod_ramo			char(3);
define _cod_zona   			char(3);
define _cod_status   		char(1);
define _prima_bruta   		dec(16,2);
define _por_vencer   		dec(16,2);
define _corriente   		dec(16,2);
define _monto_180   		dec(16,2);
define _monto_150   		dec(16,2);
define _monto_120   		dec(16,2);
define _monto_90   			dec(16,2);
define _monto_60   			dec(16,2);
define _monto_30   			dec(16,2);
define _exigible   			dec(16,2);
define _saldo   			dec(16,2);
define _carta_aviso_canc	smallint;
define _cod_acreencia   	smallint;
define _dia_cobros1   		smallint;
define _dia_cobros2   		smallint;
define _cnt_remesa			smallint;
define _fecha_aviso_canc	date;
define _fecha_desde_camp	date;
define _fecha_ult_pago		date;
define _vigencia_inic   	date;
define _vigencia_fin   		date;

set isolation to dirty read;
--set debug file to "sp_cob284b.trc"; 
--trace on;

let _motivo_rechazo		= '';
let _cod_formapag  		= '';
let _nom_formapag		= '';
let _no_documento		= '';
let _cod_sucursal  		= '';
let _nom_subramo		= '';	
let _cod_gestion		= '';	
let _nom_pagador		= '';	
let _nom_agencia		= '';	
let _cod_pagador   		= '';
let _cod_cliente		= '';
let _cod_subramo   		= '';
let _cod_agente   		= '';
let _nom_agente			= '';
let _cod_status   		= '';
let _nom_grupo			= '';
let _acreencia			= '';
let _no_poliza			= '';
let _fecha_exp			= '';
let _cod_grupo   		= '';
let _cod_pagos   		= '';
let _no_remesa			= '';
let _nom_ramo			= '';
let _cod_area   		= '';	
let _cod_ramo			= '';
let _cod_zona   		= '';	
let _periodo			= '';
let _status				= '';
let _zona				= '';
let _por_vencer			= 0.00;
let _corriente 			= 0.00;
let _monto_180 			= 0.00;
let _monto_150 			= 0.00;
let _monto_120 			= 0.00;
let _monto_90  			= 0.00;
let _monto_60  			= 0.00;
let _monto_30  			= 0.00;
let _exigible  			= 0.00;
let _saldo   			= 0.00;
let _carta_aviso_canc	= 0;
let _cod_acreencia   	= 0;
let _dia_cobros1   		= 0;
let _dia_cobros2   		= 0;
let _cnt_remesa			= 0;
let _fecha_aviso_canc	= null;
let _fecha_desde_camp	= null;
let _fecha_ult_pago		= null;
let _vigencia_inic   	= null;
let	_vigencia_fin   	= null;

create temp table temp_campana(
no_documento	char(20),
cobrada			smallint,
no_poliza		char(10),
no_remesa		char(10),
cod_gestion		char(3)) with no log; 
create index idx_campana1 on temp_campana(no_documento);
create index idx_campana2 on temp_campana(cobrada);

select fecha_desde
  into _fecha_desde_camp
  from cascampana
 where cod_campana = a_cod_campana;

foreach
	select cod_cliente,
		   cod_gestion
	  into _cod_cliente,
		   _cod_gestion
	  from cascliente
	 where cod_campana = a_cod_campana
	   and nuevo = 0
	   --and procesado = 1
	 order by monto_180 desc,monto_150 desc,monto_120 desc,monto_90 desc,monto_60 desc,monto_30 desc,corriente desc

	foreach
		select no_documento
		  into _no_documento
		  from caspoliza
		 where cod_cliente = _cod_cliente
		   and cod_campana = a_cod_campana

		call sp_sis21(_no_documento) returning _no_poliza;

		select fecha_ult_pago
		  into _fecha_ult_pago
		  from emipomae
		 where no_poliza = _no_poliza;

		if _fecha_ult_pago > _fecha_desde_camp then
			call sp_sis39(_fecha_ult_pago) returning _periodo;

			foreach
				select no_remesa 
				  into _no_remesa
				  from cobredet
				 where no_poliza = _no_poliza
				   and tipo_mov in ('P','N','X')
				   and periodo = _periodo

				select count(*)
				  into _cnt_remesa
				  from cobremae
				 where no_remesa = _no_remesa
				   and date_posteo = _fecha_ult_pago;

				if _cnt_remesa = 1 then
					exit foreach;
				end if
			end foreach

			insert into temp_campana(no_documento,no_poliza,cobrada,no_remesa,cod_gestion)
			values (_no_documento,_no_poliza,1,_no_remesa,_cod_gestion);
		else
			insert into temp_campana(no_documento,no_poliza,cobrada,no_remesa,cod_gestion)
			values (_no_documento,_no_poliza,0,'',_cod_gestion);
		end if		
	end foreach		 
end foreach

let _no_documento	= '';
let _no_poliza		= '';
let _no_remesa		= '';

foreach
	select no_documento,
		   no_poliza,
		   no_remesa,
		   cod_gestion
	  into _no_documento,
		   _no_poliza,
		   _no_remesa,
		   _cod_gestion
	  from temp_campana
	 order by cobrada desc

	select nombre
	  into _nom_gestion
	  from cobcages
	 where cod_gestion = _cod_gestion;

	select cod_ramo,
	       cod_subramo,   
	       cod_formapag,   
	       cod_zona,   
	       cod_agente,   
	       cod_sucursal,   
	       cod_area,   
	       cod_status,   
	       cod_grupo,   
	       cod_pagos,   
	       cod_pagador,   
	       dia_cobros1,   
	       dia_cobros2,   
	       vigencia_inic,   
	       vigencia_fin,   
	       exigible,   
	       por_vencer,   
	       corriente,   
	       monto_30,   
	       monto_60,   
	       monto_90,   
	       monto_120,   
	       monto_150,   
	       monto_180,   
	       saldo,   
	       cod_acreencia,   
	       prima_bruta,   
	       carta_aviso_canc,   
	       motivo_rechazo,   
	       fecha_exp
	  into _cod_ramo,			   
		   _cod_subramo,   	   
		   _cod_formapag,   	   
		   _cod_zona,   		   
		   _cod_agente,   	   
		   _cod_sucursal,   	   
		   _cod_area,   		   
		   _cod_status,   	   
		   _cod_grupo,   		   
		   _cod_pagos,   		   
		   _cod_pagador,   	   
		   _dia_cobros1,   
		   _dia_cobros2,   
		   _vigencia_inic,   
		   _vigencia_fin,   
		   _exigible,   
		   _por_vencer,   
		   _corriente,   
		   _monto_30,   
		   _monto_60,   
		   _monto_90,   
		   _monto_120,   
		   _monto_150,   
		   _monto_180,   
		   _saldo,   
		   _cod_acreencia,   
		   _prima_bruta,   
		   _carta_aviso_canc,
		   _motivo_rechazo,  
		   _fecha_exp
	  from emipoliza  
	 where no_documento = _no_documento;

	if _cod_status in ('2','4') then
		continue foreach;
	end if

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre												  
	  into _nom_subramo											  
	  from prdsubra												  
	 where cod_ramo = _cod_ramo									  
	   and cod_subramo = _cod_subramo;							  

	select nombre												  
	  into _nom_formapag										  
	  from cobforpa												  
	 where cod_formapag = _cod_formapag;						  

	select nombre
	  into _zona
	  from cobcobra
	 where cod_cobrador = _cod_zona;

	select nombre
	  into _nom_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	select descripcion
	  into _nom_agencia
	  from insagen
	 where codigo_agencia = _cod_sucursal;

	select nombre
	  into _nom_grupo
	  from cligrupo
	 where cod_grupo = _cod_grupo;

	select nombre
	  into _nom_pagador
	  from cliclien	 
	 where cod_cliente = _cod_pagador;

	let _fecha_aviso_canc = null;

	if _carta_aviso_canc = 1 then
		select fecha_aviso_canc
		  into _fecha_aviso_canc
		  from emipomae
		 where no_poliza = _no_poliza;
	end if

	select descripcion
	  into _status
	  from statuspoli
	 where cod_status = _cod_status;

	select descripcion 
	  into _acreencia
	  from acreehip
	 where cod_acreencia = _cod_acreencia;

	return _no_documento,
		   _nom_ramo,
		   _nom_subramo,
		   _nom_formapag,
		   _zona,
		   _nom_agente,
		   _nom_agencia,
		   _cod_area,
		   _status,
		   _nom_grupo,
		   _cod_pagos,
		   _nom_pagador,
		   _dia_cobros1,
		   _dia_cobros2,
		   _vigencia_inic,
		   _vigencia_fin,
		   _exigible,
		   _por_vencer,
		   _corriente,
		   _monto_30,
		   _monto_60,
		   _monto_90,
		   _monto_120,
		   _monto_150,
		   _monto_180,
		   _saldo,
		   _prima_bruta,
		   _acreencia,
		   _fecha_aviso_canc,
		   _motivo_rechazo,
		   _fecha_exp,
		   _no_remesa,
		   _nom_gestion with resume;
end foreach

drop table temp_campana;
end procedure;