-- Reporte del Cierre de Caja - Detallado
-- Creado    : 01/02/2010 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 19/05/2017 - Autor: Federico Coronado
-- SIS v.2.0 - d_cobr_cierre_caja_automatico_reporte - DEIVID, S.A.

drop procedure sp_cob232bk1;

create procedure "informix".sp_cob232bk1(a_no_caja char(10))
returning char(10),
          char(1),
          char(30),
          char(50),
          char(10),
          date,
          char(50),
          smallint,
          smallint,
          dec(16,2),
          smallint,
          smallint,
          varchar(100),
          char(1),
		  char(10),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);  --21

define _observacion			varchar(100);
define _nombre_caja			char(50);
define _recibi_de			char(50);
define _doc_remesa			char(30);
define _no_remesa			char(10);
define _no_recibo			char(10);
define _cod_chequera 		char(3);
define _tipo_remesa			char(1);
define _tipo_mov			char(1);
define _importe				dec(16,2);
define _monto				dec(16,2);
define _monto_descontado    dec(16,2);
define _importe_cobrepag 	dec(16,2);
define _tipo_tarjeta		smallint;
define _en_balance			smallint;
define _tipo_pago			smallint;
define _tipo_dato			smallint;
define _contador			smallint;
define _cantidad			smallint;
define _renglon				smallint;
define _fecha 				date;
define _efectivo    		dec(16,2);
define _cheque    	    	dec(16,2);
define _clave    	    	dec(16,2);
define _visa    	    	dec(16,2);
define _mastercard    		dec(16,2);
define _diner       		dec(16,2);
define _american    		dec(16,2);
define _resta_cobrepag      dec(16,2);
define _resta_cobredet      dec(16,2);
define _importe_det         dec(16,2);
define _resta1              dec(16,2);
define _cod_banco       	char(3);
define v_cnt_cobredet   	smallint;
define v_cnt_cobrepag   	smallint;
define _valor_negativo      smallint;

set isolation to dirty read;

drop table if exists tmp_caja;

create temp table tmp_caja(
no_remesa		char(10),
renglon			smallint,
no_recibo		char(10),
tipo_mov		char(1),
doc_remesa		char(30),
recibi_de		char(50),
tipo_pago		smallint,
tipo_tarjeta	smallint,
importe			dec(16,2),
tipo_remesa		char(1),
tabla           varchar(10),
proceso         smallint default 0
) with no log;

drop table if exists tmp_banco;

create temp table tmp_banco(
cod_banco		char(3),
doc_remesa		char(30),
recibi_de		char(50),
efectivo		dec(16,2),
cheque			dec(16,2),
clave			dec(16,2),
visa			dec(16,2),
mastercard		dec(16,2),
diner			dec(16,2),
american		dec(16,2),
observacion		varchar(10)
) with no log;

SET DEBUG FILE TO "sp_cob232bk1.trc";
trace on;


select fecha,
       cod_chequera,
	   en_balance,
	   tipo_remesa
  into _fecha,
       _cod_chequera,
	   _en_balance,
	   _tipo_remesa
  from cobcieca
 where no_caja = a_no_caja;

select nombre
  into _nombre_caja
  from chqchequ
 where cod_banco    = "146"
   and cod_chequera = _cod_chequera;

foreach
	select no_remesa,
		   recibi_de,
		   tipo_remesa
	  into _no_remesa,
		   _recibi_de,
		   _tipo_remesa
	  from cobremae
	 where fecha        = _fecha
	   and cod_chequera = _cod_chequera
	   and actualizado  = 1
	   and tipo_remesa  = _tipo_remesa
	  -- and no_remesa    = '1284567'

	let _contador = 0;

	foreach
		select renglon,
			   no_recibo,
			   tipo_mov,
			   doc_remesa,
			   monto,
			   monto_descontado
		  into _renglon,
			   _no_recibo,
			   _tipo_mov,
			   _doc_remesa,
			   _monto,
			   _monto_descontado
		  from cobredet
		 where no_remesa = _no_remesa

		let _monto = _monto - _monto_descontado;
/*		 if _no_remesa = '1074896' then 
		 
			SET DEBUG FILE TO "sp_cob232_new.trc";
			TRACE ON; 
			
		 end if
*/
	/*	let _contador = _contador + 1;

		if _contador > 1 then
			let _recibi_de = "";
		end if
*/
		insert into tmp_caja
		values (_no_remesa, _renglon, _no_recibo, _tipo_mov, _doc_remesa, _recibi_de, null, null, _monto, _tipo_remesa,'cobredet',0);		
	end foreach

	foreach
		select renglon,
			   tipo_pago,
			   tipo_tarjeta,
			   importe
		  into _renglon,
			   _tipo_pago,
			   _tipo_tarjeta,
			   _importe
		  from cobrepag
		 where no_remesa = _no_remesa

		select count(*)
		  into _cantidad
		  from tmp_caja
		 where no_remesa = _no_remesa 
		   and renglon   = _renglon;

/*		if _cantidad <> 0 then
			update tmp_caja
			   set tipo_pago    = _tipo_pago,
			       tipo_tarjeta = _tipo_tarjeta,
				   importe      = _importe
			 where no_remesa    = _no_remesa
			   and renglon      = _renglon;
		else*/
			insert into tmp_caja
			values (_no_remesa, _renglon, "", "P", "", "", _tipo_pago, _tipo_tarjeta, _importe,"",'cobrepag',0);		
/*		end if		*/
	end foreach
end foreach

let _tipo_dato = 1;
foreach
	select no_remesa
	  into _no_remesa
	  from tmp_caja
  group by 1
  order by 1
/*
	select count(*)
	  into v_cnt_cobrepag
	  from tmp_caja
	 where no_remesa = _no_remesa
	   and tabla 	 = 'cobrepag';
	   
	select count(*)
	  into v_cnt_cobredet
	  from tmp_caja
	 where no_remesa = _no_remesa
	   and tabla 	 = 'cobredet';
			
	if v_cnt_cobrepag >= v_cnt_cobredet then */
	let _valor_negativo = 0;
			foreach
				select no_recibo,
					   tipo_mov,
					   doc_remesa,
					   recibi_de,
					   tipo_remesa,
					   importe
				  into _no_recibo,	 
					   _tipo_mov,
					   _doc_remesa,
					   _recibi_de, 
					   _tipo_remesa,
					   _importe_det
				  from tmp_caja
				 where no_remesa = _no_remesa
				   and tabla	 = 'cobredet'
			  order by renglon 
				 
				let _efectivo     = 0.00; 
				let _cheque       = 0.00;   
				let _clave        = 0.00;  
				let _visa    	  = 0.00;
				let _mastercard   = 0.00;
				let _diner        = 0.00;    
				let _american     = 0.00;
				
				foreach
					select tipo_pago, 
						   tipo_tarjeta, 
						   importe,
						   renglon
					  into _tipo_pago,
						   _tipo_tarjeta, 
						   _importe,
						   _renglon
					  from tmp_caja
					 where no_remesa = _no_remesa
					   and tabla 	 = 'cobrepag'
					   and proceso = 0
				  order by renglon
				  exit foreach;
				end foreach
				
				if _tipo_mov = 'B' and _importe_det <> 0 then
					let _importe = 0;
				end if
				
				if abs(_importe) > abs(_importe_det) then
					let _valor_negativo = 1;
				--	let _resta_cobredet = _importe - _importe_det;
				else
					let _valor_negativo = 0;
				--	let _resta_cobredet =   _importe_det - _importe;
				end if
				
				let _resta_cobredet = _importe - _importe_det;
				
				if _resta_cobredet <= 0 and _valor_negativo = 0 then
						update tmp_caja
						   set importe 		= 0,
							   proceso      = 1
						 where no_remesa 	= _no_remesa
						   and tabla 	 	= 'cobrepag'
						   and renglon   	= _renglon					   
						   and proceso 	 	= 0;
						   
						if _tipo_pago <> 4 then
							let _tipo_tarjeta = 0;
						end if
						let _tipo_pago = _tipo_pago + _tipo_tarjeta;
						
						if _tipo_pago = 1 then
							let _efectivo = _importe;
						elif _tipo_pago = 2 then
							let _cheque = _importe;
						elif _tipo_pago = 3 then
							let _clave = _importe;
						elif _tipo_pago = 5 then
							let _visa = _importe;
						elif _tipo_pago = 6 then
							let _mastercard = _importe;
						elif _tipo_pago = 7 then
							let _diner = _importe;
						elif _tipo_pago = 8 then
							let _american = _importe;
						end if	     
						
					while abs(_resta_cobredet) != 0	   
						foreach
							select tipo_pago, 
								   tipo_tarjeta, 
								   importe,
								   renglon
							  into _tipo_pago,
								   _tipo_tarjeta, 
								   _importe,
								   _renglon
							  from tmp_caja
							 where no_remesa = _no_remesa
							   and tabla 	 = 'cobrepag'
							   and proceso = 0
						  order by renglon
						  exit foreach;
						end foreach
					
						let _resta1 = _resta_cobredet;
						let _resta_cobredet = _importe - abs(_resta_cobredet);
						
						if _resta_cobredet <= 0 then 
							
							update tmp_caja
							   set importe 		= 0,
								   proceso      = 1
							 where no_remesa 	= _no_remesa
							   and tabla 	 	= 'cobrepag'
							   and renglon   	= _renglon					   
							   and proceso 	 	= 0;
						else
						
							let _importe = abs(_resta1);
							
							update tmp_caja
							   set importe 		= _resta_cobredet
							 where no_remesa 	= _no_remesa
							   and tabla 	 	= 'cobrepag'
							   and renglon   	= _renglon					   
							   and proceso 	 	= 0;
							   
							let _resta_cobredet = 0;
						end if
						
						if _tipo_pago <> 4 then
							let _tipo_tarjeta = 0;
						end if

						let _tipo_pago = _tipo_pago + _tipo_tarjeta;
						
						if _tipo_pago = 1 then
							let _efectivo = _importe + _efectivo;
						elif _tipo_pago = 2 then
							let _cheque = _importe + _cheque;
						elif _tipo_pago = 3 then
							let _clave = _importe + _clave;
						elif _tipo_pago = 5 then
							let _visa = _importe + _visa;
						elif _tipo_pago = 6 then
							let _mastercard = _importe + _mastercard;
						elif _tipo_pago = 7 then
							let _diner = _importe + _diner;
						elif _tipo_pago = 8 then
							let _american = _importe + _american;
						end if	 
						   
					END WHILE
				else
					--let _importe = _importe_det;
					
					if abs(_importe) < _resta_cobredet then
						update tmp_caja
						   set importe 		= 0,
							   proceso      = 1
						 where no_remesa 	= _no_remesa
						   and tabla 	 	= 'cobrepag'
						   and renglon   	= _renglon					   
						   and proceso 	 	= 0;
						   
						if _tipo_pago <> 4 then
							let _tipo_tarjeta = 0;
						end if
						
						let _tipo_pago = _tipo_pago + _tipo_tarjeta;
						
						if _tipo_pago = 1 then
							let _efectivo = _importe;
						elif _tipo_pago = 2 then
							let _cheque = _importe;
						elif _tipo_pago = 3 then
							let _clave = _importe;
						elif _tipo_pago = 5 then
							let _visa = _importe;
						elif _tipo_pago = 6 then
							let _mastercard = _importe;
						elif _tipo_pago = 7 then
							let _diner = _importe;
						elif _tipo_pago = 8 then
							let _american = _importe;
						end if	     
						
					while abs(_resta_cobredet) != 0	   
						foreach
							select tipo_pago, 
								   tipo_tarjeta, 
								   importe,
								   renglon
							  into _tipo_pago,
								   _tipo_tarjeta, 
								   _importe,
								   _renglon
							  from tmp_caja
							 where no_remesa = _no_remesa
							   and tabla 	 = 'cobrepag'
							   and proceso = 0
						  order by renglon
						  exit foreach;
						end foreach
					
						let _resta1 = _resta_cobredet;
						let _resta_cobredet = abs(_importe) - abs(_resta_cobredet);
						
						if _resta_cobredet <= 0 then 
							
							update tmp_caja
							   set importe 		= 0,
								   proceso      = 1
							 where no_remesa 	= _no_remesa
							   and tabla 	 	= 'cobrepag'
							   and renglon   	= _renglon					   
							   and proceso 	 	= 0;
						else
						
							let _importe = abs(_resta1);
							
							update tmp_caja
							   set importe 		= _resta_cobredet
							 where no_remesa 	= _no_remesa
							   and tabla 	 	= 'cobrepag'
							   and renglon   	= _renglon					   
							   and proceso 	 	= 0;
							   
							let _resta_cobredet = 0;
						end if
						
						if _tipo_pago <> 4 then
							let _tipo_tarjeta = 0;
						end if

						let _tipo_pago = _tipo_pago + _tipo_tarjeta;
						
						if _tipo_pago = 1 then
							let _efectivo = _importe + _efectivo;
						elif _tipo_pago = 2 then
							let _cheque = _importe + _cheque;
						elif _tipo_pago = 3 then
							let _clave = _importe + _clave;
						elif _tipo_pago = 5 then
							let _visa = _importe + _visa;
						elif _tipo_pago = 6 then
							let _mastercard = _importe + _mastercard;
						elif _tipo_pago = 7 then
							let _diner = _importe + _diner;
						elif _tipo_pago = 8 then
							let _american = _importe + _american;
						end if	 
						   
					END WHILE	   
						
					else
						update tmp_caja
						   set importe 		= _resta_cobredet
						 where no_remesa 	= _no_remesa
						   and tabla 	 	= 'cobrepag'
						   and renglon   	= _renglon					   
						   and proceso 	 	= 0;
						let _importe = _importe_det;   

						if _tipo_pago <> 4 then
							let _tipo_tarjeta = 0;
						end if
						
						let _tipo_pago = _tipo_pago + _tipo_tarjeta;
						
						if _tipo_pago = 1 then
							let _efectivo = _importe;
						elif _tipo_pago = 2 then
							let _cheque = _importe;
						elif _tipo_pago = 3 then
							let _clave = _importe;
						elif _tipo_pago = 5 then
							let _visa = _importe;
						elif _tipo_pago = 6 then
							let _mastercard = _importe;
						elif _tipo_pago = 7 then
							let _diner = _importe;
						elif _tipo_pago = 8 then
							let _american = _importe;
						end if	
					end if
				end if
				return _no_recibo, 
					   _tipo_mov,
					   _doc_remesa,
					   _recibi_de,
					   a_no_caja,
					   _fecha,
					   _nombre_caja,
					   _tipo_pago,
					   _tipo_tarjeta, 
					   _efectivo,
					   _en_balance,
					   _tipo_dato,
					   '',
					   _tipo_remesa,
					   _no_remesa,
					   _cheque,
					   _clave,
					   _visa,
					   _mastercard,
					   _diner,
					   _american
					   with resume;
		end foreach
end foreach

let _tipo_dato = 2;

foreach
	select tipo_pago,
		   cod_banco,
		   tipo_tarjeta,
		   monto,
		   cuenta,
		   nombre,
		   observacion	
	  into _tipo_pago,
		   _cod_banco,
		   _tipo_tarjeta,
		   _importe,
		   _doc_remesa,
		   _recibi_de,
		   _observacion	
	  from cobcieca2
	 where no_caja = a_no_caja
	 order by renglon

	if _tipo_pago <> 4 then
		let _tipo_tarjeta = 0;
	end if
	
	let _efectivo     = 0.00; 
	let _cheque       = 0.00;   
	let _clave        = 0.00;  
	let _visa    	  = 0.00;
	let _mastercard   = 0.00;
	let _diner        = 0.00;    
	let _american     = 0.00; 

	if _tipo_pago = 6 then
		let _tipo_pago = 1;
	end if

	let _tipo_pago = _tipo_pago + _tipo_tarjeta;
	
	if _tipo_pago = 1 then
		let _efectivo = _importe;
	elif _tipo_pago = 2 then
		let _cheque = _importe;
	elif _tipo_pago = 3 then
		let _clave = _importe;
	elif _tipo_pago = 5 then
		let _visa = _importe;
	elif _tipo_pago = 6 then
		let _mastercard = _importe;
	elif _tipo_pago = 7 then
		let _diner = _importe;
	elif _tipo_pago = 8 then
		let _american = _importe;
	end if

	
	insert into tmp_banco
	values (_cod_banco, _doc_remesa,_recibi_de, _efectivo, _cheque, _clave, _visa, _mastercard, _diner, _american,_observacion);	
		
end foreach

foreach
	select doc_remesa,
	       recibi_de,
		   sum(efectivo),
		   sum(cheque),
		   sum(clave),
		   sum(visa),
		   sum(mastercard),
		   sum(diner),
		   sum(american),
		   observacion
	  into _doc_remesa,
		   _recibi_de,
		   _efectivo,
		   _cheque,
		   _clave,
		   _visa,
		   _mastercard,
		   _diner,
		   _american,
		   _observacion
	  from tmp_banco
  group by 1,2,10
	
	let _tipo_pago = 0;
	let _tipo_tarjeta = 0;
	return "", 
	       "",
		   _doc_remesa,
		   _recibi_de,
		   a_no_caja,
		   _fecha,
		   _nombre_caja,
		   _tipo_pago,
		   _tipo_tarjeta, 
		   _efectivo,
		   _en_balance,
		   _tipo_dato,
		   _observacion,
		   '',
		   '',
		   _cheque,
		   _clave,
		   _visa,
		   _mastercard,
		   _diner,
		   _american
		   with resume;
end foreach
--drop table tmp_caja;
drop table tmp_banco;
end procedure
-- if( compute_no_recibo = 0,0,1)