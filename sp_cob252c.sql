-- Procedimiento corrige ganchito de carta de avisos de emipomae que se quitaron al Renovar
-- Creado    : 17/03/2017 - Autor: Henry Girón
drop procedure sp_cob252c;
create procedure sp_cob252c()
returning	char(20) as no_documento,
			date as fecha_aviso_canc,
			char(10) as no_aviso,
			char(10) as user_imprimir,
			dec(16,2) as saldo_mas_60,
			integer as procesado,
            char(10) as poliza_ant,
            char(10) as poliza_vig ;

define _error_desc			varchar(100);
define _error_isam			integer;
define _error				integer;
define _no_documento		char(20);
define _no_poliza			char(10);
define _no_poliza_vig		char(10);
define _periodo				char(8);
define _por_vencer_n		dec(16,2);
define _corriente_n			dec(16,2);
define _por_vencer			dec(16,2);
define _exigible_n			dec(16,2);
define _monto_90_n			dec(16,2);
define _monto_60_n			dec(16,2);
define _monto_30_n			dec(16,2);
define _corriente			dec(16,2);
define _exigible			dec(16,2);
define _monto_180			dec(16,2);
define _monto_150			dec(16,2);
define _monto_120			dec(16,2);
define _monto_90			dec(16,2);
define _monto_60			dec(16,2);
define _monto_30			dec(16,2);
define _saldo_n				dec(16,2);
define _saldo				dec(16,2);
define _fecha_aviso_canc	date;
define _fecha_actual		date;
define _user_imprimir		char(10);
define _no_aviso     		char(10);
define _saldo_mas_60		dec(16,2); 
define _procesado           integer;

--set debug file to "sp_cob252c.trc";
--trace on;
set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
	return '','01/01/1900',_error_desc,'',0.00,_error,'','';
end exception 

let _fecha_actual = current;
let _periodo = sp_sis39(_fecha_actual);	   

foreach
	select distinct no_poliza
	  into _no_poliza
	  from tmp_pdf_aviso
	 where no_aviso = '170321'
	   and estatus = 'I'
	   --and no_poliza = '1004523'
	   
		select no_documento
		  into _no_documento
		  from emipomae
		 where no_poliza = _no_poliza
--		 and estatu = '1'
		 ;	   		 
		 call sp_sis21(_no_documento) returning _no_poliza_vig;
	call sp_cob245a("001","001",_no_documento,_periodo,_fecha_actual)	 
	returning	_por_vencer,      
				_exigible,         
				_corriente,        
				_monto_30,         
				_monto_60,         
				_monto_90,
				_monto_120,
				_monto_150,
				_monto_180,
				_saldo;

	let _saldo_mas_60 = _monto_60 + _monto_90 + _monto_120 + _monto_150 + _monto_180;

	   if _saldo_mas_60 > 0 then  -- si tiene mayor a 60 corrgir estados

		select max(no_aviso)
		  into _no_aviso
		  from avisocanc
		 where no_documento = _no_documento;
		 
		select fecha_imprimir, user_imprimir, no_poliza
		  into _fecha_aviso_canc, _user_imprimir, _no_poliza
		  from avisocanc
		 where no_documento = _no_documento
		 and no_aviso = _no_aviso;		 		 		 
		 
		 let _procesado = 1;
		 {
		update avisocanc
		  set  estatus = 'Y', motivo_desmarca = 'CASO:COB252C:170321', user_desmarca = _user_imprimir
		where no_documento in (_no_documento) and no_aviso <> _no_aviso and estatus = 'I'; 
		 
		update avisocanc
		  set motivo_desmarca = 'CASO:COB252C:170317', user_desmarca = _user_imprimir
		where no_documento in (_no_documento) and no_aviso = _no_aviso  and estatus = 'I'; 
		 
		update emipomae  
	   	   set carta_aviso_canc = 0,fecha_aviso_canc = null
		 where no_documento in (_no_documento) ;
		 
		update emipomae  
	   	   set carta_aviso_canc = 1,fecha_aviso_canc = _fecha_aviso_canc		 
 		 where no_poliza = _no_poliza_vig;
		 }
		 else
		 
		 let _procesado = 0;
		 
		end if
			   
		return _no_documento,
			   _fecha_aviso_canc,
			   _no_aviso,
			   _user_imprimir,
			   _saldo_mas_60,
			   _procesado,
			   _no_poliza,
			   _no_poliza_vig
			   with resume;
	
	
end foreach

end
end procedure;