-- Pool de logistica para cancelacion - estados impresion 1- 2- 3-  
-- Creado		: 16/2/2016 - Autor: Henry Giron. 
-- execute procedure sp_log007("00908") 

drop procedure sp_log007; 
create procedure "informix".sp_log007(a_no_aviso char(15))  
returning	char(20), -- no_documento
			char(20), -- nombre_cliente
			char(50), -- nombre_agente
			char(50), -- nombre_acreedor
			char(50), -- nombre_ramo
			float,    -- saldo
			char(10), -- no_poliza
			char(15), -- user_imp_aviso_log
			date,     -- date_imp_aviso_log
			char(15), -- no_aviso
			char(10), -- cedula
			char(3),  -- cod_ramo
			char(5),  -- cod_agente
			char(5),  -- cod_acreedor 
			char(1),  -- imprimir 
            smallint, -- imp_aviso_log  
			char(1),  -- correo  
			smallint, -- copias
			date,     -- fecha_cese			
			char(50); -- Email Cliente

 define _no_documento     char(20);
 define _nombre_cliente   char(20); 
 define _nombre_agente    char(50);
 define _nombre_acreedor  char(50); 
 define _nombre_ramo      char(50);
 define _saldo            float;  
 define _no_poliza        char(10);  
 define _user_imp_aviso_log char(15);  
 define _date_imp_aviso_log  date;
 define _no_aviso         char(15); 
 define _cedula           char(10); 
 define _cod_ramo         char(3); 
 define _cod_agente       char(5); 
 define _cod_acreedor     char(5); 
 define _imp_aviso_log    smallint;
 define _imprimir         char(1); 
 define _desmarcada       char(1);
 define _leasing		  smallint;
 define _renglon		  smallint;
 define _cod_ase		  char(10);
 define _ano_char		  char(4);
 define _mes_char		  char(2);
 define _fecha_actual	  date;
 define _clase				char(1);
 
 define _dias_180			dec(16,2);
 define _dias_150			dec(16,2);
 define _dias_120			dec(16,2); 
 define _dias_90			dec(16,2);
 define _dias_60			dec(16,2);
 define _dias_30			dec(16,2); 
 define _por_vencer_c	    dec(16,2);
 define _corriente_c		dec(16,2);
 define _exigible_c			dec(16,2);
 define _dias_30_c			dec(16,2);
 define _dias_60_c			dec(16,2);
 define _dias_90_c			dec(16,2);
 define _dias_120_c			dec(16,2);
 define _dias_150_c			dec(16,2);
 define _dias_180_c			dec(16,2); 
 define _saldo_c 			dec(16,2); 
 define _saldo_sin_mora		dec(16,2);
 define _saldo_pago			dec(16,2);
 define _estatus			char(1);
 define _hay_pago			smallint;
 define _periodo_c			char(7);
 define _fecha_marcar  		date;	
 define _fecha_imprimir		date;
define _fecha_proceso		date;
define _fecha_cese  		date;			
define _copias              smallint;
define _email_cli           char(50);
define _estado			    char(1);

 
 let _imprimir = "0";
 let _desmarcada = '0';
 let _saldo_sin_mora	= 0;
 let _hay_pago			= 0;
 let _copias = 0;          
 let _email_cli = '';
 let _estado = '';

set isolation to dirty read;  	 
let _fecha_actual		= today;
if month(_fecha_actual) < 10 then
	let _mes_char = '0'|| month(_fecha_actual);
else
	let _mes_char = month(_fecha_actual);
end if

let _ano_char = year(_fecha_actual);
let _periodo_c  = _ano_char || "-" || _mes_char;

foreach  
 select  d.no_documento, 
		 d.nombre_cliente, 
		 d.nombre_agente, 
		 d.nombre_acreedor, 
		 d.nombre_ramo, 
		 d.saldo, 
		 d.no_poliza, 
		 d.user_imp_aviso_log, 
		 d.date_imp_aviso_log,
		 d.no_aviso,
		 d.cedula,
		 d.cod_ramo,
		 d.cod_agente,
		 d.cod_acreedor,
         d.imp_aviso_log,
		 d.renglon,
		 d.desmarca,
		 d.fecha_imprimir,
		 d.fecha_proceso,		 		 
		 d.dias_30,
		 d.dias_60,
		 d.dias_90,
		 d.dias_120,
		 d.dias_150,
		 d.dias_180,
		 d.estatus,
         d.clase,		 --HG:ASTANZIO,17/05/2019
		 d.fecha_marcar,
		 d.email_cli
	into _no_documento, 
		 _nombre_cliente, 
		 _nombre_agente, 
		 _nombre_acreedor, 
		 _nombre_ramo, 
		 _saldo, 
		 _no_poliza, 
		 _user_imp_aviso_log, 
		 _date_imp_aviso_log,
		 _no_aviso,
		 _cedula,
		 _cod_ramo,
		 _cod_agente,
		 _cod_acreedor,
         _imp_aviso_log,
		 _renglon,
		 _desmarcada,
		 _fecha_imprimir,
		 _fecha_proceso,
	     _dias_30,
	     _dias_60,
	     _dias_90,
	     _dias_120,
	     _dias_150,
	     _dias_180,
         _estatus,
         _clase,
         _fecha_marcar,
		 _email_cli
	  from avicanpar a, avisocanc d
     where (( d.estatus in ('M','X') and user_marcar = 'DEIVID') or d.estatus in ('I'))  -- Henry, solicitud  usuario NSOLIS 2/8/2016
	   --and  ((d.clase = '2' )) --
     --  and (d.imprimir_log = 0 or d.imprimir_log is null)	   
       and a.cod_avican = d.no_aviso
       and d.saldo > 0 and d.exigible > 0	 -- Henry: 16/08/2016, se esta colocando para igualar ambos pool. solicitud de Gisela y Nimia   	   
       and a.cod_avican = (a_no_aviso)
	   
	   if _saldo <= 0 then
			continue foreach; 
	   end if
	   
		 call sp_cob782(_no_poliza,_renglon,_no_aviso,'L') returning _estado; --_estatus;
		 
		 if _estado is null then 
		     let _estado = 'I';  --estatus
		 end if		
		 
		 if _estado in ('M','E') then 
		      continue foreach;
		 end if	   
	   
	   --if _desmarcada = 1 then
	   --	continue foreach;
	   --end if	   
	  --if _desmarcada <> 8 then
	  --  //
	  	call sp_cob245a("001","001",_no_documento,_periodo_c,_fecha_actual)
		returning	_por_vencer_c,
					_exigible_c,
					_corriente_c,
					_dias_30_c,
					_dias_60_c,
					_dias_90_c,
					_dias_120_c,
					_dias_150_c,
					_dias_180_c,
					_saldo_c;

		if _saldo_c = 0  then
			continue foreach;
		end if

		let _dias_90  	= _dias_90+_dias_120+_dias_150+_dias_180;
		let _dias_120 	= 0.00;
		let _dias_150 	= 0.00;
		let _dias_180 	= 0.00;
		let _saldo_pago = 0.00;

		if _cod_ramo in ("004","016","018","019") then
			let _saldo_sin_mora = _saldo - (_dias_60+_dias_90);
		else
			let _saldo_sin_mora = _saldo - (_dias_60+_dias_90);
		end if

		if _estatus not in ('G') then
			if _fecha_imprimir is null then
			   let _fecha_imprimir = _fecha_proceso;
			end if

			let _hay_pago = 0;

			select count(*) -- saldo
			  into _hay_pago
			  from emipomae
			 where no_poliza = _no_poliza
			   and no_documento	= _no_documento
			   and fecha_ult_pago >= _fecha_imprimir;

			if _hay_pago >= 1 or _exigible_c <= 0 then
				let _saldo_pago = 0.00;

				select saldo
				  into _saldo_pago
				  from emipomae
				 where no_poliza = _no_poliza
				   and no_documento	= _no_documento
				   and fecha_ult_pago >= _fecha_imprimir;

				if _saldo_pago is null then
				   let _saldo_pago = 0.00;
				end if
				
				if (_saldo <= _saldo_sin_mora and abs(_saldo - _saldo_sin_mora) <= 5.00) then
					continue foreach;
				else
					 -- si el pago es en el dia
					 --trace off;
					call sp_cob245a("001","001",_no_documento,_periodo_c,_fecha_actual)
					returning	_por_vencer_c,
								_exigible_c,
								_corriente_c,
								_dias_30_c,
								_dias_60_c,
								_dias_90_c,
								_dias_120_c,
								_dias_150_c,
								_dias_180_c,
								_saldo_c;
					  --trace on;
					if _saldo_c = 0 then
						continue foreach;
					end if
				end if
			end if
		end if
	  --  //
	   --end if
	   
	   select leasing
	     into _leasing
		 from emipomae
		where no_poliza = _no_poliza;
		
	   if _leasing = 1 then	--La poliza es leasing
			foreach
				select cod_asegurado
				  into _cod_ase
				  from emipouni
				 where no_poliza = _no_poliza
				
				select nombre
				  into _nombre_acreedor
				  from cliclien
				 where cod_cliente = _cod_ase;
				exit foreach;	 
			end foreach
			update avisocanc
			   set nombre_acreedor = _nombre_acreedor
			 where no_aviso        = a_no_aviso
			   and renglon         = _renglon;
			   
		end if
		let _fecha_cese = null;
		if _clase = '1' and _imp_aviso_log in ('2','3') then  --HG:17/05/2019, ASTANZIO CORREO del CESE
			--if _cod_ramo in ("002","020") then   --JBRITO06/01/2020
				let _imp_aviso_log = '4';
				let _fecha_cese = _fecha_marcar;
			--end if
		end if
		
		call sp_sis389(_no_poliza) returning _copias; 
		if _copias is null then
			let _copias = 1;
		end if			 
		


	return _no_documento,
			_nombre_cliente,
			_nombre_agente,
			_nombre_acreedor,
			_nombre_ramo,
			_saldo,
			_no_poliza,
			_user_imp_aviso_log,
			_date_imp_aviso_log,
			_no_aviso,
			_cedula,
			_cod_ramo,
			_cod_agente,
			_cod_acreedor,
			_imprimir,
            _imp_aviso_log,
			_estado,    --_clase,
			_copias,
			_fecha_cese,
			_email_cli
		   with resume;

end foreach
end procedure
