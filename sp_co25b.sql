-- CONSULTA DE PRIMAS POR COBRAR
-- Procedimiento que extrae los Saldos de la Poliza
 
-- Creado    : 26/09/2000 - Autor: Marquelda Valdelamar 
-- Modificado: 21/03/2001 - Autor: Marquelda Valdelamar
-- Modificado: 18/01/2011 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_co25a_bk;
create procedure "informix".sp_co25a_bk(
a_compania 		char(3), 
a_sucursal 		char(3), 
a_no_documento  char(20),
a_fecha_desde	date,
a_fecha_hasta	date)
returning	date,  	   -- fecha
			char(20),  -- referencia
			char(20),  -- no. documento
			dec(16,2), -- monto
			dec(16,2), -- prima neta
			dec(16,2), -- saldo
			char(7),   -- periodo
			char(10),  -- poliza
			char(100); -- tipo factura

define _tipo_fac		char(100);
define v_referencia		char(20);
define v_documento		char(20);
define _no_poliza		char(10);
define _no_requis		char(10);
define _no_remesa		char(10);
define _periodo_vig_fin	char(7);
define _periodo2		char(7);
define _periodo			char(7);
define v_periodo		char(7);
define v_no_endoso		char(5);
define _no_unidad		char(5);
define v_cod_endomov	char(3);
define v_cod_tipocan	char(3);
define _cod_tipoprod	char(3);
define _cod_banco		char(3);
define _nueva_renov		char(1);
define _tipo_remesa		char(1);
define _tipo_mov		char(1);
define v_prima_orig		dec(16,2);
define _por_vencer		dec(16,2);
define _corriente 		dec(16,2);
define _exigible  		dec(16,2);
define _monto_90		dec(16,2);
define _monto_60  		dec(16,2);
define _monto_30  		dec(16,2);
define v_monto			dec(16,2);
define v_prima			dec(16,2);
define v_saldo			dec(16,2);	 
define _saldo			dec(16,2);
define _flag_periodo	smallint;
define _cant_uni		smallint;
define _anulado			smallint;
define _pagado			smallint;
define _vigencia_final	date;
define _fecha_anterior	date;
define _fecha_anulado   date;
define v_fecha_emision	date;
define v_fecha_cobredet date;
define _fecha_desde		date;
define v_fecha			date;

set isolation to dirty read;

--drop table tmp_saldo3;
--set debug file to "sp_co25_bk.trc";
--trace on;

create temp table tmp_saldo3(
fecha           date,
referencia      char(20),
no_documento    char(20),
monto           dec(16,2),
prima_neta      dec(16,2),
periodo			char(7),
no_poliza       char(10),
tipo_fac        char(100)) with no log;
create index id1_tmp_saldo3 on tmp_saldo3(periodo, fecha, referencia, no_documento);
create index id2_tmp_saldo3 on tmp_saldo3(fecha);   

if a_fecha_desde = a_fecha_hasta then
	foreach
		select vigencia_inic
		  into _fecha_desde
		  from emipomae
		 where no_documento = a_no_documento
		   and vigencia_inic < today
		 order by vigencia_final desc
		exit foreach;
	end foreach
else
	let _fecha_desde = a_fecha_desde;
end if 

call sp_sis39(_fecha_desde) returning _periodo;
call sp_sis39(a_fecha_hasta) returning _periodo2;
let _flag_periodo = 0;

foreach
	select no_poliza,
		   nueva_renov,
		   vigencia_final
	  into _no_poliza,
		   _nueva_renov,
		   _vigencia_final
	  from emipomae
	 where no_documento = a_no_documento
	   and actualizado  = 1

   	let _saldo = 0.00;
	
	if _flag_periodo = 0 then
		let _fecha_anterior = _fecha_desde - 1;
		call sp_cob33d(a_compania,a_sucursal,a_no_documento,_periodo,_fecha_anterior) 
		returning _por_vencer,
				  _exigible,
				  _corriente,
				  _monto_30,
				  _monto_60,
				  _monto_90,
				  _saldo;

	  	insert into tmp_saldo3(
				fecha,
				referencia,
				no_documento,
				monto,
				prima_neta,
				periodo,
				no_poliza,
				tipo_fac)
		values(	_fecha_desde,
				'SALDO ANTERIOR',		
				'',
				_saldo,    
				0.00,    
				'',   
				_no_poliza,
				'');
		let _flag_periodo = 1;
	end if

	let v_referencia = 'FACTURA';
	let _saldo		 = 0.00;
	let	_por_vencer	 = 0.00;	
	let	_exigible 	 = 0.00;
	let	_corriente	 = 0.00;			 
	let	_monto_30 	 = 0.00;
	let	_monto_60	 = 0.00;
	let	_monto_90	 = 0.00;

   --CALL sp_sis39(_vigencia_inic) Returning  _periodo_vig_ini;
	call sp_sis39(_vigencia_final) returning _periodo_vig_fin;
   
	foreach
		select fecha_emision,
			   no_factura,
			   prima_bruta,
			   prima_neta,
			   periodo,
			   cod_endomov,   
			   cod_tipocan, 
			   no_endoso
		  into v_fecha,		
			   v_documento, 
			   v_monto,     
			   v_prima,     
			   v_periodo,
			   v_cod_endomov,   
			   v_cod_tipocan,
			   v_no_endoso
		  from endedmae
		 where no_poliza   = _no_poliza
		   and actualizado = 1
		   and activa = 1
		   --and fecha_emision between _fecha_desde and a_fecha_hasta

		-- Tipo de Factura
		let _tipo_fac = "";

		if v_cod_endomov = '011' then
			if _nueva_renov = 'N' then
			   let _tipo_fac = 'NUEVA';
			else			 
			   let _tipo_fac = 'RENOVACION';
			end if
		elif v_cod_endomov = '002' then
			select nombre
			  into _tipo_fac
			  from endtican
			 where cod_tipocan = v_cod_tipocan;
		else
			select nombre                       
			  into _tipo_fac                    
			  from endtimov                     
			 where cod_endomov = v_cod_endomov;

			if v_cod_endomov in ('004','005','006') then
				select count(*)
				  into _cant_uni
				  from endeduni
				 where no_endoso = v_no_endoso
				   and no_poliza = _no_poliza;
			   
				if _cant_uni = 1 then
					select no_unidad
					  into _no_unidad
					  from endeduni
					 where no_endoso = v_no_endoso
					   and no_poliza = _no_poliza;
					let _tipo_fac = trim(_tipo_fac) || ' UNIDAD #' || trim(_no_unidad);
				end if
			end if
		end if

		insert into tmp_saldo3(
				fecha,
				referencia,
				no_documento,
				monto,
				prima_neta,
				periodo,
				no_poliza,
				tipo_fac)
		values(	v_fecha,
				v_referencia,		
				v_documento,
				v_monto,    
				v_prima,    
				v_periodo,
				_no_poliza,
				_tipo_fac);

		let v_referencia = 'FACTURA';
	end foreach;

	foreach
		select no_recibo,
			   monto,
			   prima_neta,
			   no_remesa,
			   tipo_mov
		  into v_documento,
			   v_monto,
			   v_prima,
			   _no_remesa,
			   _tipo_mov
		  from cobredet
		 where no_poliza   = _no_poliza
		   and actualizado = 1
		   and tipo_mov IN ('P', 'N', 'X')
		   --and fecha between _fecha_desde and a_fecha_hasta
 
		let v_monto = v_monto * -1;
		let v_prima = v_prima * -1;

		select fecha,
		       tipo_remesa,
			   periodo
		  into v_fecha,		
			   _tipo_remesa, 
			   v_periodo   
		  from cobremae
		 where no_remesa = _no_remesa;

	    if   _tipo_remesa = 'C' THEN
			let v_referencia = 'COMPROBANTE';
		else
			if _tipo_mov = 'X' then
				let v_referencia = 'AJUSTE';
			else
				let v_referencia = 'RECIBO';
			end if
	    end if

		let _tipo_fac = 'REMESA ' || _no_remesa;

		insert into tmp_saldo3(
				fecha,
				referencia,
				no_documento,
				monto,
				prima_neta,
				periodo,
				no_poliza,
				tipo_fac)
		values(	v_fecha,
				v_referencia,		
				v_documento,
				v_monto,    
				v_prima,    
				v_periodo,   
				_no_poliza,
				_tipo_fac);
	end foreach
--trace on;

	let v_referencia = 'CHEQUE';

	foreach
		select monto,
			   prima_neta,
			   no_requis
		  into v_monto,
			   v_prima,
			   _no_requis
		  from chqchpol
		 where no_poliza = _no_poliza

		--let v_monto = v_monto * -1;
		--let v_prima = v_prima * -1;
		select fecha_impresion,
			   no_cheque,
			   periodo,
			   pagado,
			   cod_banco,
			   anulado,
			   fecha_anulado
		  into v_fecha,		
			   v_documento, 
			   v_periodo,
			   _pagado,
			   _cod_banco,   
			   _anulado,
			   _fecha_anulado
		  from chqchmae
		 where no_requis 		= _no_requis;
		   --and fecha_impresion	between _fecha_desde and a_fecha_hasta;

		select nombre
		  into _tipo_fac
		  from chqbanco
		 where cod_banco = _cod_banco;

			{IF _pagado  = 1 AND   					Puesto en comentario para mostrar la informacion de cheques 26/05/2011
				   _anulado = 0 THEN

					INSERT INTO tmp_saldo3(
					fecha,
					referencia,
					no_documento,
					monto,
					prima_neta,
					periodo,
					no_poliza,
					tipo_fac
					)
					VALUES(
					v_fecha,
					v_referencia,		
					v_documento,
					v_monto,    
					v_prima,    
					v_periodo,   
					_no_poliza,
					_tipo_fac
					);

			END IF}

		if _pagado  = 1 then		
			insert into tmp_saldo3(
					fecha,
					referencia,
					no_documento,
					monto,
					prima_neta,
					periodo,
					no_poliza,
					tipo_fac)
			values(	v_fecha,
					v_referencia,	
					v_documento,
					v_monto,
					v_prima, 
					v_periodo, 
					_no_poliza,
					_tipo_fac);
		end if

		if _anulado = 1 then
			call sp_sis39(_fecha_anulado) returning v_periodo;
			let v_monto = v_monto * -1;
			let v_prima = v_prima * -1;

			insert into tmp_saldo3(
					fecha,
					referencia,
					no_documento,
					monto,
					prima_neta,
					periodo,
					no_poliza,
					tipo_fac)
			values(	_fecha_anulado,
					v_referencia,	
					v_documento,
					v_monto,
					v_prima, 
					v_periodo, 
					_no_poliza,
					_tipo_fac);
		end if
	end foreach
end foreach

let v_saldo = 0;

foreach
	select fecha,
		   referencia,
		   no_documento,
		   monto,
		   prima_neta,
		   periodo,
		   no_poliza,
		   tipo_fac
	  into v_fecha,
		   v_referencia,
		   v_documento,
		   v_monto,    
		   v_prima,    
		   v_periodo,
		   _no_poliza,
		   _tipo_fac
	  from tmp_saldo3
	 where fecha between _fecha_desde and a_fecha_hasta
	 order by periodo, fecha, referencia, no_documento

	let v_saldo = v_saldo + v_monto;

	return	v_fecha,
			v_referencia,  
			v_documento,  
			v_monto,      
			v_prima, 
			v_saldo,     
			v_periodo,
			_no_poliza,
			_tipo_fac with resume;
end foreach;
drop table tmp_saldo3;
end procedure
